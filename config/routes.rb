Lanes::API.routes.for_extension 'lanes' do

    root_view :lanes_root_view

    get 'job-statuses/:id.json' do
        wrap_reply do
            status = Lanes::Job.status_for_id(params[:id])
            raise ActiveRecord::RecordNotFound unless status
            std_api_reply :update, status, success: true
        end
    end

end
