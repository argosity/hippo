module Lanes
    API.routes.draw do
        get "default-records" do
            { success: true, data: Lanes::API.default_records }
        end

        Extensions.each do | ext |
            ext.route(self)
        end

        get '/*' do
            content_type 'text/html'
            erb :index
        end
    end
end
