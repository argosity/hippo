module Hippo
    module Templates
        class Contact < Mail

            attr_reader :params

            def initialize(params)
                @params = params
            end

            def to
                Hippo.config.support_email
            end

            def subject
                "[#{Hippo.config.product_name} Contact] #{params['subject']}"
            end

            def variables
                params
            end

        end
    end
end
