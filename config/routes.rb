Hippo::API.routes.for_extension 'hippo' do

    get 'job-statuses/:id.json' do
        wrap_reply do
            status = Hippo::Job.status_for_id(params[:id])
            raise ActiveRecord::RecordNotFound unless status
            std_api_reply :update, status, success: true
        end
    end

    post "user-sessions.json", &Hippo::API::Handlers::UserSession.create
    get "user-sessions/test.json", &Hippo::API::Handlers::UserSession.check

    delete "user-sessions/:id.json" do
        wrap_reply do
            { success: true, message: "Logout succeeded", data: {}, token: '' }
        end
    end

    get 'bootstrap.json' do
        wrap_reply do
            { success: true, data: Hippo::Extensions.client_bootstrap_data }
        end
    end

    resources Hippo::User

end
