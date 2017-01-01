require 'action_cable'
# require 'action_cable/subscription_adapter/postgresql'

module Lanes
    module API
        module Cable
            mattr_reader :server
            mattr_reader :config

            def self.handle_request(request)
                @@server.call(request.env)
            end

            class Channel < ActionCable::Channel::Base
            end

            class Connection < ActionCable::Connection::Base
                identified_by :current_user

                def connect
                    unless cookies['user_id'] &&
                            self.current_user = Lanes::User
                                                    .where(id: cookies['user_id']).first
                        Lanes.logger.warn("Rejecting ws connection due to unauthorized access by user_id #{cookies['user_id']}")

                        reject_unauthorized_connection
                    end
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
