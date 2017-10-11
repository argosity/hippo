module Hippo

    class Asset < Hippo::Model
        belongs_to_tenant

        include Hippo::Concerns::AssetUploader[:file]

        belongs_to :owner, polymorphic: true

        def present?
            super && file.present?
        end

        def path(size)
            Hippo.config.api_path + Hippo.config.assets_path_prefix + '/' + file_data[size]['id']
        end

        def url(size = 'original')
           "https://#{Hippo::Tenant.current.slug}.#{Hippo.config.website_domain}#{path(size)}"
        end
    end

end
