module Lanes

    class Asset < Lanes::Model

        include Lanes::Concerns::AssetUploader[:file]

        belongs_to :owner, polymorphic: true

        def present?
            super && file.present?
        end

        def path(size)
            Lanes.config.api_path + Lanes.config.assets_path_prefix + '/' + file_data[size]['id']
        end
    end

end
