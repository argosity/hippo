require_relative '../../user'

module Hippo
    module Access

        module Roles

            class Support < Role
                self.read << ::Hippo::User
            end

        end

    end
end
