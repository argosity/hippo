module Hippo::API::Handlers

    class Tenant < Hippo::API::ControllerBase

        def show
            std_api_reply(:retrieve, Hippo::Tenant.current.bootstrap_data, success: true)
        end

        def update
            tenant = Hippo::Tenant.current
            tenant.assign_attributes(data.slice(*PUBLIC_ATTRS))
            success = tenant.save
            if success && tenant.slug_previously_changed?
                Hippo::Tenant.system.perform do
                    Hippo::Templates::TenantChange.create(tenant).deliver
                end
            end
            std_api_reply(:update, tenant,
                          only: PUBLIC_ATTRS,
                          success: success)
        end
    end

end
