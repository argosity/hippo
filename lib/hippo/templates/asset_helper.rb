module Hippo
    module Templates

        class AssetHelper
            def url_for(file, size)
                Hippo.config.asset_host +
                    Hippo.config.api_path +
                    Hippo.config.assets_path_prefix +
                    '/' + file['file_data'][size]['id']
            end

            def exists?(file)
                !!(file && file['file_data'])
            end
        end

    end
end
