require_relative '../user'

module Lanes
    module Access

        module Roles

            class Support < Role
                self.read << ::Lanes::User
            end

        end

    end
end
