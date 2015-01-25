module Lanes
    API.routes.draw do

        post "/user-session.json" do
            wrap_json_reply do
                user = User.where(login: data['login']).first
                if user && user.authenticate(data['password'])
                    session[:user_id] = user.id
                    { success: true, message: "Login succeeded", data: user.workspace_data }
                else
                    { success: false, message: "Login failed", errors: { login: 'failed' }, data: {} }
                end
            end
        end

        delete "/user-session/:id.json" do
            session.destroy
            wrap_json_reply do
                { success: true, message: "Logout succeeded", data: {} }
            end
        end

        resources User

    end
end
