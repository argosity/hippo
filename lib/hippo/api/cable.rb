require "lite_cable"

module Hippo
    module API
        module Cable
            mattr_reader :server
            mattr_reader :config

            def self.handle_request(request)
                @@server.call(request.env)
            end

            class Channel < LiteCable::Channel::Base
            end

            class Connection < LiteCable::Connection::Base
                identified_by :current_user

                def connect
                    token = request.params['token']
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

                if Hippo.config.api_use_any_cable

                else
                    require "lite_cable/server"
                    @@server = LiteCable::Server::Middleware.new(
                        Hippo::API::Root, connection_class: Hippo::API::Cable::Connection
                    )
                end
                Updates.relay!
            end

        end


    end
end
