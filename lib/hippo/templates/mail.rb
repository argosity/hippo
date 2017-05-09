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

            def self.create(record)
                Hippo::Mailer.from_template(self.new(record))
            end
        end
    end
end
