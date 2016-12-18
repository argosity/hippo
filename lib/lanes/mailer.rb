require 'mail'
module Lanes

    module Mailer
        @@configured = false

        def self.set_defaults(settings = SystemSettings.for_ext(:lanes))
            smtp = settings['smtp'] || {}
            method = Lanes.env.production? ? :smtp : :test
            Mail.defaults do
                delivery_method(method, {
                                    user_name: smtp['login'],
                                    password:  smtp['password'],
                                    address:   smtp['server']
                                })

            end
            @@configured = true
        end

        Lanes::SystemSettings.on_change(:lanes, call_now: true) do |settings|
            self.set_defaults(settings)
        end

        def self.new(args = {}, &block)
            args[:from] = SystemSettings.for_ext(:lanes).dig('smtp', 'from')
            set_defaults unless @@configured
            Mail::Message.new(args, &block)
        end

        def self.deliver(args = {}, &block)
            args[:from] = SystemSettings.for_ext(:lanes).dig('smtp', 'from')
            set_defaults unless @@configured
            mail = self.new(args, &block)
            mail.deliver
            mail
        end
    end

end
