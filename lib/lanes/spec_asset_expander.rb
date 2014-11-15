module Lanes
    class SpecAssetExpander

        def expand(src_dir, src_path)
            pathname = src_path.gsub(/^\/?assets\//, '').gsub(/\.js$/, '')

            asset_bundle.assets(pathname).flat_map { |asset|
                "/#{asset.gsub(/^\//, '')}?body=true"
            }
        end

        private

        def asset_bundle
            return AssetBundle.new
        end

        class AssetBundle
            def assets(pathname)
                context.get_original_assets(pathname)
            end

            private

            def context
                @context ||= ActionView::Base.new.extend(GetOriginalAssetsHelper)
            end

            module GetOriginalAssetsHelper
                def get_original_assets(pathname)
                    assets_environment.find_asset(pathname).to_a.map do |processed_asset|
                        case processed_asset.content_type
                        when "text/css"
                            path_to_stylesheet(processed_asset.logical_path, debug: true)
                        when "application/javascript"
                            path_to_javascript(processed_asset.logical_path, debug: true)
                        end
                    end
                end
            end
        end
    end
end
