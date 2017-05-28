module Hippo::Templates
    class TenantChange < Mail

        def initialize(tenant)
            @tenant = tenant
        end

        def to
            @tenant.email
        end

        def subject
            "The login address for #{Hippo.config.product_name} has changed"
        end

        def variables
            super.merge(
                'slug' => @tenant.slug,
                'domain' => @tenant.domain
            )
        end
    end
end
