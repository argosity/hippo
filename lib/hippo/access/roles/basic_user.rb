module Hippo
    module Access

        module Roles

            class BasicUser < Role

                self.read << Hippo::Tenant
                self.read << Hippo::Subscription
                self.read << Hippo::Page

            end

        end

    end
end
