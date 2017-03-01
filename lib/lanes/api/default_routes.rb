require_relative "handlers/asset.rb"

module Lanes
    API.routes.draw do
        # WS endpoint must come first
        get Lanes.config.api_path + '/ws' do
            API::Cable.handle_request(request)
        end

        Extensions.each(reversed: true) do | ext |
            ext.route(self)
        end

        put Lanes.config.api_path + '/lanes/system-settings.json',
            &SystemSettings.update_handler

        get Lanes.config.api_path + '/lanes/system-settings.json',
            &SystemSettings.get_handler

        post Lanes.config.api_path + '/asset',
             &API::Handlers::Asset.saver

        get Lanes.config.api_path + '/asset/*',
            &API::Handlers::Asset.getter

        post Lanes.config.api_path + '/dev-file-change.json' do
            API::PubSub.publish("file-change", data)
            "OK"
        end

    end

    API.set_root_view :lanes_root_view

end
