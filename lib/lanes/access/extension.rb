module Lanes
    module Access
        class Extension < Lanes::Extensions::Definition
            self.uses_workspace = true

            identifier "lanes-access"

            components :modal, :grid, :select_field

            root_path Pathname.new(__FILE__).dirname.expand_path

            def stylesheet_include
                'lanes/access/styles'
            end

            def javascript_include
                'lanes/access'
            end

            def client_namespace
                'Access'
            end

            def client_paths
                []
            end

            def client_bootstrap_data(view)
                data = { roles: Lanes::Access::Role.all_available }
                if (user_id = view.session['user_id']) && (user = Lanes::User.where( id: user_id ).first)
                    data.merge!(user.workspace_data)
                end
                data
            end

        end

    end
end
