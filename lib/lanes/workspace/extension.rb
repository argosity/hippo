module Lanes
    module Workspace
        class Extension < Lanes::Extensions::Definition

            identifier "lanes-workspace"

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

        end

    end
end
