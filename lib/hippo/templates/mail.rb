module Hippo
    module Templates
        class Mail < Liquid

            def to
                raise 'virtual method to called, this should be implemented by child class'
            end

            def subject
                raise 'virtual method subject called, this should be implemented by child class'
            end

            def pathname
                root_path.join('mail', filename)
            end

            def variables
                { 'product_name' => Hippo.config.product_name }
            end

            def reply_to
                nil
            end

            def self.create(*arg)
                Hippo::Mailer.from_template(self.new(*arg))
            end

            def attachments
                {}
            end
        end
    end
end
