require 'mail'

module Lanes

    module Mailer

        def self.create(args = {})
            config = SystemSettings.for_ext(:lanes)['smtp'] || {}
            delivery = delivery_method_config(config)
            Mail::Message.new(args) do
                from "\"#{config['from_name']}\" <#{config['from_email']}>"
                delivery_method delivery
            end
        end

        def self.delivery_method_config(config)
            return :test unless Lanes.env.production?
            {
                smtp: {
                    address: config['server'],
                    user_name: config['login'],
                    password: config['password']
                }
            }
        end

    end
end
