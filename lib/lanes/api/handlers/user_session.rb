require 'jwt'
require_relative '../../access/user'

module Lanes::API::Handlers


    module UserSession
        def self.user_for_token(token)
            payload = JWT.decode token, Lanes.config.session_secret_key_base, true, { :algorithm => 'HS256' }
            if payload.length && (uid = payload[0]['uid'])
                return Lanes::User.where(id: uid).first
            end
        end


        def self.create
            lambda do
                wrap_reply(with_transaction: false) do
                    user = Lanes::User.where(login: data['login']).first
                    Lanes.logger.warn "Found User: #{user.id}"

                    if user && user.authenticate(data['password'])
                        token = JWT.encode({'uid' => user.id}, Lanes.config.session_secret_key_base, 'HS256')
                        { success: true, message: "Login succeeded", data: user.workspace_data, token: token }
                    else
                        { success: false, message: "Login failed", errors: { login: 'failed' }, data: {} }
                    end
                end
            end
        end


        def self.check
            lambda do
                wrap_reply do
                    user = Lanes::API::AuthenticationProvider.user_for_request(self)
                    if user
                        { success: true, message: "Login succeeded",
                          data: user.workspace_data.merge(
                              csrf: session[:csrf]
                          )
                        }
                    else
                        { success: true, message: "not logged in", errors: { login: 'none' }, data: {} }
                    end
                end
            end
        end

    end

end
