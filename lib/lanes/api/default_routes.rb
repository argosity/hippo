module Lanes
    API.routes.draw do

        put Lanes.config.api_path + '/system-settings.json',
            &SystemSettings.update_handler

        post Lanes.config.api_path + '/asset',
             &API::Handlers::Asset.saver

        get Lanes.config.api_path + '/asset/*',
            &API::Handlers::Asset.getter

        get Lanes.config.api_path + '/ws' do
            API::Cable.server.call(env)
        end

        post Lanes.config.api_path + '/dev-file-change.json' do
            API::PubSub.publish("file-change", data)
            "OK"
        end

        Extensions.each(reversed: true) do | ext |
            ext.route(self)
        end

    end
end
