module Hippo::API::Handlers

    class Subscription < Hippo::API::ControllerBase

        def show
            plan = Hippo::Subscription
                       .find(params['id'])
                       .as_json.merge(
                           authorization: Hippo::Payments.payment_authorization
                       )
            std_api_reply(:retrieve, plan, success: true)
        end

        def update
            tenant = Hippo::Tenant.current
            subscription = Hippo::Subscription.find(data['id'])
            Hippo::Payments.set_tenant_payment_method(
                tenant, subscription, data['nonce']
            )
            success = subscription.errors.none?
            if success
                tenant.subscription = subscription
                tenant.save!
            end
            std_api_reply(:retrieve, subscription, success: success)
        end

        def destroy
            tenant = Hippo::Tenant.current
            if tenant.subscription_id != params['id'].to_i
                return std_api_reply(:destroy, {}, success: false)
            end
            success = Hippo::Payments.cancel_subscription(tenant)
            tenant.save! if success
            std_api_reply(:retrieve, tenant.subscription, success: success)
        end
    end

end
