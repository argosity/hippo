require 'mail'

module Hippo

    module Mailer

        def self.create
            config = SystemSettings.for_ext(:hippo)['smtp'] || {}
            delivery = delivery_method_config(config)
            Mail::Message.new do
                from "\"#{config['from_name']}\" <#{config['from_email']}>"
                delivery_method delivery[:via], delivery[:config]
            end
        end

        def self.delivery_method_config(config)
            return {
                via: Hippo.env.production? ? :smtp : :test,
                config: {
                    address: config['server'],
                    user_name: config['login'],
                    password: config['password']
                }
            }
        end

    end
end
