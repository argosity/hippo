module Lanes
    module API
        module AuthenticationHelper
            def authenticate!(model, type)
                authentication = Lanes::API.config.authentication_provider.new(environment:env, params:params)
                unless authentication.allowed_access_to?(model, type)
                    error!({ errors: {user: "Access Denied"}, message: @authentication.error_message }, 401)
                end
                @authentication
            end

            def authentication
                @authentication
            end

            def session
                env['rack.session']
            end
        end
    end
end
