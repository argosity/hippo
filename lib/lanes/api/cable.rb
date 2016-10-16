require 'action_cable'
# require 'action_cable/subscription_adapter/postgresql'

module Lanes
    module API
        module Cable
            mattr_reader :server
            mattr_reader :config


            class Channel < ActionCable::Channel::Base
            end

            class Connection < ActionCable::Connection::Base
                identified_by :current_user

                def connect
                    self.current_user = Lanes::User.where(id: cookies['user_id']).first

                    reject_unauthorized_connection unless current_user
                end

                protected

                def cookies
                    request.session
                end
            end

            def self.configure
                require_relative 'updates'
                @@config = ActionCable::Server::Configuration.new
                config.logger = Lanes.logger
                config.cable = {
                    'adapter' => 'postgresql'
                }
                config.connection_class = -> { Connection }
                config.allowed_request_origins = -> (env) {
                    "http://localhost:9292"
                }

                ActionCable::Server::Base.config = config
                @@server = ActionCable.server
                Updates.relay!
            end

        end


    end
end
