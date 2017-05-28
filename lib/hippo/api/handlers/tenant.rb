module Hippo::API::Handlers

    class Tenant < Hippo::API::ControllerBase
        PUBLIC_ATTRS = %w{slug name}

        def show
            std_api_reply(:retrieve, Hippo::Tenant.current, only: PUBLIC_ATTRS)
        end

        # isn't really a create, but FE will think it's creating because we don't expose the id
        def create
            tenant = Hippo::Tenant.current
            tenant.assign_attributes(data.slice(*PUBLIC_ATTRS))
            success = tenant.save
            if success
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
