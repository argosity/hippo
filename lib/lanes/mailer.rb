require 'mail'
module Lanes

    module Mailer
        @@configured = false

        def self.set_defaults(settings = SystemSettings.for_ext(:lanes))
            smtp = settings['smtp'] || {}
            Mail.defaults do
                Lanes.env.production?
                delivery_method Lanes.env.production? ? :smtp : :test, {
                                    from:      smtp['from'],
                                    address:   smtp['server'],
                                    user_name: smtp['username'],
                                    password:  smtp['password']
                                }
            end
            @@configured = true
        end

        Lanes::SystemSettings.on_change(:lanes, call_now: true) do |settings|
            self.set_defaults(settings)
        end

        def self.new(*args, &block)
            set_defaults unless @@configured
            Mail::Message.new(args, &block)
        end

        def self.deliver(*args, &block)
            set_defaults unless @@configured
            mail = self.new(args, &block)
            mail.deliver
            mail
        end
    end

end
