require_relative '../workspace/extension'
require_relative '../access'

module Lanes
    module Access
        class Extension < Lanes::Extensions::Definition

            identifier "lanes-access"

            components 'grid', 'modal'

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

            def roles_for_client
                Lanes::Access::Role.all_available.map do |role|
                    { id: role.to_s.demodulize.underscore, name: role.to_s.demodulize }
                end
            end
            def client_bootstrap_data
                data = { roles: roles_for_client }
                # if (user_id = view.session['user_id']) && (user = Lanes::User.where( id: user_id ).first)
                #     data.merge!(user.workspace_data)
                # end
                data
            end

        end

    end
end
