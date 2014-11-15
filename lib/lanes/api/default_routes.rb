module Lanes
    module API

        Root.get '/' do
            content_type 'text/html'
            erb :index
        end

        Root.get "default-records" do
            { success: true, data: Lanes::API.default_records }
        end

        Root.post "/user-session.json" do
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

        Root.delete "/user-session.json" do
            session.destroy
            { success: true, message: "Logout succeeded", data: {} }
        end

        Root.build_route User



    end
end
