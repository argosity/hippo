module Hippo
    module Access

        module Roles

            class BasicUser < Role

                self.read << Hippo::Tenant

            end

        end

    end
end
