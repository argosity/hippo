module Lanes
    API.routes.draw do
        prefix = Lanes.config.mounted_at

        post "#{prefix}/user-session.json" do
            wrap_reply do
                user = User.where(login: data['login']).first
                Lanes.logger.warn "Found User: #{user}"

                if user && user.authenticate(data['password'])
                    session[:user_id] = user.id
                    { success: true, message: "Login succeeded", data: user.workspace_data }
                else
                    { success: false, message: "Login failed", errors: { login: 'failed' }, data: {} }
                end
            end
        end

        delete "#{prefix}/user-session/:id.json" do
            session.destroy
            wrap_reply do
                { success: true, message: "Logout succeeded", data: {} }
            end
        end

        resources User

    end
end
