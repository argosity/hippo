module Lanes
    module API
        class AuthenticationProvider

            def self.user_for_request(request)
                token = request.params['jwt']
                token ? User.for_jwt_token(token) : nil
            end

            attr_reader :request

            def initialize(request)
                @request=request
            end

            def current_user
                @current_user ||= AuthenticationProvider.user_for_request(request)
            end

            def error_message
                current_user ? "User not found" : error_message_for_access
            end

            def error_message_for_access
                return "Unable to " + case request.request_method
                                      when 'GET' then "read"
                                      when 'POST','PATCH','PUT' then "write"
                                      when 'DELETE' then "delete"
                                      else
                                          "perform action"
                                      end
            end

            def allowed_access_to?(klass, options = {})
                return true if options[:public] == true and current_user.nil?
                return false if current_user.nil?
                case request.request_method
                when 'GET'
                    klass.can_read_attributes?(request.params, current_user)
                when 'POST', 'PATCH', 'PUT'
                    klass.can_write_attributes?(request.params, current_user)
                when 'DELETE'
                    klass.can_delete_attributes?(request.params, current_user)
                else
                    false
                end
            end

            def wrap_request(req)
                if current_user
                    ::Lanes::User.scoped_to(current_user) do | user |
                        yield
                    end
                else
                    fail_request(req)
                end
            end

            def wrap_model_access(model, req, options = {})
                if allowed_access_to?(model, options)
                    ::Lanes::User.scoped_to(current_user) do | user |
                        yield
                    end
                else
                    fail_request(req)
                end
            end

            def fail_request(req)
                Lanes.logger.warn request.env['HTTP_X_TESTING_USER']
                Lanes.logger.warn "Unauthorized access attempted to #{req.url}"
                req.halt( 401, Oj.dump({
                    success:false, errors: {user: "Access Denied"}, message: "Access Denied"
                }))
            end
        end

    end
end
