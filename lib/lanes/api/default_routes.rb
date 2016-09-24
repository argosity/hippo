module Lanes
    API.routes.draw do

        put Lanes.config.api_path + '/system-settings.json',
            &SystemSettings.update_handler

        post Lanes.config.api_path + '/asset',
             &API::Handlers::Asset.saver

        get Lanes.config.api_path + '/asset/*',
            &API::Handlers::Asset.getter

        get Lanes.config.api_path + '/boostrap.json' do
            content_type 'application/json'
            client_bootstrap_data
        end

        Extensions.each(reversed: true) do | ext |
            ext.route(self)
        end

    end
end
