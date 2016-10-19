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
                    reject_unauthorized_connection unless
                        cookies['user_id'] &&
                        self.current_user = Lanes::User.where(id: cookies['user_id']).first
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
                config.cable = Lanes.config.cable
                config.connection_class = -> { Connection }
                config.allowed_request_origins = -> (host) {
                    host
                }

                ActionCable::Server::Base.config = config
                @@server = ActionCable.server
                Updates.relay!
            end

        end


    end
end
