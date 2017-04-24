Lanes::API.routes.for_extension 'lanes' do

    get 'job-statuses/:id.json' do
        wrap_reply do
            status = Lanes::Job.status_for_id(params[:id])
            raise ActiveRecord::RecordNotFound unless status
            std_api_reply :update, status, success: true
        end
    end

    post "user-sessions.json", &Lanes::API::Handlers::UserSession.create
    get "user-sessions/test.json", &Lanes::API::Handlers::UserSession.check

    delete "user-sessions/:id.json" do
        wrap_reply do
            { success: true, message: "Logout succeeded", data: {}, token: '' }
        end
    end

    get 'bootstrap.json' do
        wrap_reply do
            { success: true, data: Lanes::Extensions.client_bootstrap_data }
        end
    end

    resources Lanes::User

end
