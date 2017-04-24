require_relative '../../user'

module Lanes::API::Handlers


    module UserSession

        def self.create
            lambda do
                wrap_reply(with_transaction: false) do
                    user = Lanes::User.where(login: data['login']).first
                    if user && user.authenticate(data['password'])
                        { success: true, message: "Login succeeded",
                          data: user.workspace_data.merge(token: user.jwt_token) }
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
