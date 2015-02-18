module Lanes
    module Access

        module Roles

            class Administrator < Role

                # The admin can access all the things
                def self.can_access_locked_roles?(roles)
                    true
                end

                def can_read?(model)
                    true
                end

                def can_write?(model)
                    true
                end

                def can_delete?(model)
                    true
                end

                lock User, :password_digest

            end

        end

    end
end
