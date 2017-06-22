require 'mail'

module Hippo

    module Mailer
        class << self

            def create
                config = SystemSettings.for_ext(:smtp)
                delivery = delivery_method_config(config)
                Mail::Message.new do
                    from "\"#{config['from_name']}\" <#{config['from_email']}>"
                    delivery_method delivery[:via], delivery[:config]
                end
            end

            def delivery_method_config(config)
                config = Hippo.config.secrets.smtp || {}
                {
                    via: Hippo.env.production? ? :smtp : :test,
                    config: {
                        address: config['address'],
                        user_name: config['user_name'],
                        password: config['password'],
                        enable_starttls_auto: true,
                        port: 587
                    }
                }
            end

            def from_template(template)
                mail = create
                mail.content_type = 'text/html; charset=UTF-8'
                mail.body = template.render
                mail.to = template.to
                mail.subject = template.subject
                mail
            end
        end
    end
end
