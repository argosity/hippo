require "action_cable"

module Hippo
    module API
        module Cable
            mattr_reader :server
            mattr_reader :config

            def self.handle_request(request)
                @@server.call(request.env)
            end

            class Connection < ActionCable::Connection::Base
                identified_by :current_user

                def connect
                    token = request.params['token']
                    Hippo.logger_debug("NEW WS CONN: #{token}")

                    begin
                        self.current_user = User.for_jwt_token(token) if token
                    rescue JWT::DecodeError
                    end
                    unless self.current_user
                        Hippo.logger.warn("Rejecting ws connection due to unauthorized access")
                        reject_unauthorized_connection
                    end
                end

                protected

                def cookies
                    request.session
                end
            end

            def self.configure
                require_relative './updates'
                @@config = ActionCable::Server::Configuration.new
                config.logger = Hippo.logger
                config.cable = Hippo.config.cable
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
