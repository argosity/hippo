require 'mail'

module Hippo

    module Mailer
        class << self

            def create
                config = SystemSettings.for_ext(:hippo)['smtp'] || {}
                delivery = delivery_method_config(config)
                Mail::Message.new do
                    from "\"#{config['from_name']}\" <#{config['from_email']}>"
                    delivery_method delivery[:via], delivery[:config]
                end
            end

            def delivery_method_config(config)
                return {
                    via: Hippo.env.production? ? :smtp : :test,
                    config: {
                        address: config['server'],
                        user_name: config['login'],
                        password: config['password']
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
