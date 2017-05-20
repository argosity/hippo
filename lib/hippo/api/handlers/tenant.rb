module Hippo::API::Handlers

    class Tenant < Hippo::API::ControllerBase
        PUBLIC_ATTRS = %w{slug name}

        def show
            std_api_reply(:retrieve, Hippo::Tenant.current, only: PUBLIC_ATTRS)
        end

        # isn't really a create, but FE will think it's creating because we don't expose the id
        def create
            Hippo::Tenant.current.assign_attributes(data.slice(*PUBLIC_ATTRS))
            std_api_reply(:update, Hippo::Tenant.current,
                          only: PUBLIC_ATTRS,
                          success: Hippo::Tenant.current.save)
        end
    end
end
