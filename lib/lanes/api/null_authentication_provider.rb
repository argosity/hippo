module Lanes

    module API

        class DummyUser
            def can_read?(*args)
                true
            end
            def can_write?(*args)
                true
            end
            def can_delete?(*args)
                true
            end
        end

        class AuthenticationProvider
            USER = DummyUser.new

            def initialize(request)
            end

            def current_user
                USER
            end

            def wrap_reply(model, req)
                yield
            end
            def wrap_model_access(model, req, options)
                yield
            end

        end
    end
end
