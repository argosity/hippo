module Lanes
    module Access

        module Roles

            class Support < Role
                self.read << User
            end

        end

    end
end
