require 'braintree'

module Hippo

    module Payments
        extend self

        def gateway
            cc = Hippo::Configuration.secrets.payments.braintree
            ::Braintree::Gateway.new(
                ::Braintree::Configuration.new(
                    environment: cc['sandbox'] ? :sandbox : :production,
                    merchant_id: cc['merchant_id'],
                    public_key:  cc['public_key'],
                    private_key: cc['private_key'],
                    logger:      Hippo.logger
                )
            )
        end

        def payment_authorization
            gw = ::Braintree::ClientTokenGateway.new(gateway)
            gw.generate
        end

        def sync_plans
            ::Braintree::PlanGateway.new(gateway).all.each do |bt|
                subscription = Hippo::Subscription.find_or_initialize_by(subscription_id: bt.id)
                subscription.update_attributes(
                    name: bt.name, description: bt.description,
                    price: bt.price, trial_duration: bt.trial_duration
                )
                subscription.save!
            end
            true
        end

        def update_customer_for_tenant(tenant)
            gateway.customer.update(
                tenant.metadata['bt_customer_id'],
                company: tenant.name,
                email: tenant.email,
                phone: tenant.phone_number
            )
        end

        def create_customer_for_tenant(tenant)
            result = gateway.customer.create(
                company: tenant.name,
                email: tenant.email,
                phone: tenant.phone_number
            )
            if result.success?
                tenant.metadata['bt_customer_id'] = result.customer.id
            end
        end

        def set_tenant_payment_method(tenant, subscription, nonce)
            result = if tenant.metadata['payment_method_id']
                         gateway.payment_method.update(
                             tenant.metadata['payment_method_id'],
                             payment_method_nonce: nonce)
                     else
                         gateway.payment_method.create(
                             customer_id: tenant.metadata['bt_customer_id'],
                             payment_method_nonce: nonce,
                             options: { make_default: true })
                     end

            if result.success?
                tenant.metadata['payment_method_id'] = result.payment_method.token
            else
                subscription.errors.add(:base, result.errors.map(&:message).first)
                return false
            end

            attrs = { plan_id: subscription.subscription_id,
                      payment_method_token: tenant.metadata['payment_method_id'] }

            result = if tenant.metadata['bt_plan_id']
                         gateway.subscription.update(
                             tenant.metadata['bt_plan_id'],
                             attrs
                         )
                     else
                         gateway.subscription.create(attrs)
                     end

            if result.success?
                tenant.metadata['bt_plan_id'] = result.subscription.id
                return true
            else
                subscription.errors.add(:base, result.errors.map(&:message).first)
                return false
            end
        end

        def cancel_subscription(tenant)
            result = gateway.subscription.cancel(
                tenant.metadata['bt_plan_id']
            )
            if result.success?
                tenant.metadata.delete('bt_plan_id')
                tenant.subscription = nil
                return true
            else
                tenant.subscription.errors.add(:base, result.errors.map(&:message).first)
                return false
            end
        end

    end

    Tenant.observe(:create) do |tenant|
        Payments.create_customer_for_tenant(tenant)
    end

    # Tenant.observe(:update) do |tenant|
    #     Payments.update_customer_for_tenant(tenant)
    # end

end
