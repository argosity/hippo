module Hippo::API::Handlers

    class Contact
        def self.sender(return_path)
            lambda do
                Hippo::Templates::Contact.create(params).deliver
                redirect to(return_path)
            end
        end
    end

end
