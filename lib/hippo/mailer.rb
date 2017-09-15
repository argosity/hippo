require 'mail'

module Hippo

    module Mailer

        class TestMailer < Mail::TestMailer
            def deliver!(mail)
                retval = super
                Hippo.logger.info { mail.encoded }
                retval
            end
        end

        class << self

            def create
                config = SystemSettings.for_ext(:smtp)
                Mail::Message.new do
                    from "\"#{config['from_name']}\" <#{config['from_email']}>"
                    if Hippo.env.production?
                        delivery_method :smtp, delivery_method_config(config)
                    else
                        delivery_method TestMailer
                    end
                end
            end

            def delivery_method_config(config)
                Hippo::Tenant.system.perform do
                    config = Hippo.config.secrets.smtp || {}
                    {
                        address: config['address'],
                        user_name: config['user_name'],
                        password: config['password'],
                        enable_starttls_auto: true,
                        port: 587
                    }
                end
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
