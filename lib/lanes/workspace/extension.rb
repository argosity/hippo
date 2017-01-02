module Lanes
    module Workspace
        class Extension < Lanes::Extensions::Definition

            identifier "lanes-workspace"
            components 'toolbar', 'modal'

            root_path Pathname.new(__FILE__).dirname.expand_path

            def stylesheet_include
                'lanes/workspace/styles'
            end

            def javascript_include
                'lanes/workspace'
            end

            def client_namespace
                'Workspace'
            end

            def client_paths
                []
            end

            def each_static_asset
                super{ | entry | yield entry }
                [ 'lanes/fonts/fontawesome-webfont.woff',
                  'lanes/fonts/fontawesome-webfont.woff2' ].each { | asset | yield asset }
            end
        end

    end
end
