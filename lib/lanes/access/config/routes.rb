require_relative '../user'
require_relative '../../api/handlers/user_session'

module Lanes
    Lanes::API.routes.for_extension 'lanes-access' do

        post "user-sessions.json", &API::Handlers::UserSession.create

        get "user-sessions/test.json", &API::Handlers::UserSession.check

        delete "user-sessions/:id.json" do
            wrap_reply do
                { success: true, message: "Logout succeeded", data: {}, token: '' }
            end
        end

        resources User

    end
end
