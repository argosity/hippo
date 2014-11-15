module Sinatra

    module RequestWrapper

        def wrap_request(model, params, parent_attribute)

            authentication = Lanes::API::AuthenticationProvider.new(
              request_type: request.request_method,
              session:      session,
              params:       params
            )

            unless authentication.allowed_access_to?(model)
                halt( 401, Oj.dump({
                    success:false, errors: {user: "Access Denied"}, message: authentication.error_message
                }))
            end
            ::Lanes::User.scoped_to(authentication.current_user) do | user |
                Lanes.logger.debug "User   : #{user.id} (#{user.login})"
                Lanes.logger.debug "Params : #{request.params}"

                params[:nested_attribute] = Hash[ parent_attribute, params[parent_attribute] ] if parent_attribute

                wrap_json_reply do
                    yield authentication
                end

            end
        end

        def wrap_json_reply
            response = yield
            if false == response[:success]
                status(406)
            end
            Oj.dump(response, mode: :compat)
        end

    end


end
