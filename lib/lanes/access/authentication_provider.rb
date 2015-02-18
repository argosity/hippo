module Lanes
    module API
        class AuthenticationProvider

            def initialize(session:nil, params:nil, request_type: type)
                @session = session
                @params  = params
                @request_type = request_type
            end

            def current_user
                @current_user ||= Lanes::User.where(id: @session['user_id']).first
            end

            def error_message
                current_user ? "User not found" : error_message_for_access
            end

            def error_message_for_access
                return "Unable to " + case @request_type
                                      when 'GET' then "read"
                                      when 'POST','PATCH','PUT' then "write"
                                      when 'DELETE' then "delete"
                                      else
                                          "perform action"
                                      end
            end

            def allowed_access_to?(klass)
                return false if current_user.nil?
                case @request_type
                when 'GET'
                    klass.can_read_attributes?(@params,current_user)
                when 'POST','PATCH','PUT'
                    klass.can_write_attributes?(@params,current_user)
                when 'DELETE'
                    klass.can_delete_attributes?(@params,current_user)
                else
                    false
                end
            end


            def wrap_request(model, req)
                if allowed_access_to?(model)
                    ::Lanes::User.scoped_to(current_user) do | user |
                        yield
                    end
                else
                    Lanes.logger.warn "Unauthorized access attempted to #{req}"
                    req.halt( 401, Oj.dump({
                      success:false, errors: {user: "Access Denied"}, message: "Access Denied"
                    }))
                end
            end
        end

    end
end
