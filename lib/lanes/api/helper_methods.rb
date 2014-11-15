module Lanes
    module API

        module HelperMethods

            def bootstrap_data
                Oj.dump Extension.bootstrap_data(self)
            end

            def user_data
                if (user_id = session[:user_id]) && (user = Lanes::User.where( id: user_id ).first)
                    Oj.dump(user.workspace_data, mode: :compat)
                else
                    {}
                end
            end

            def csrf_token
                Rack::Csrf.csrf_token(env)
            end

            def lanes_api_url
                Lanes.config.mounted_at
            end

            def data
                @json_data ||= Oj.load( request.body.read )
            end
        end

    end
end
