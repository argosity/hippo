require_relative "handlers/asset.rb"

unless Lanes.env.production?
    require_relative("test_specs")
end

module Lanes
    API.routes.draw do
        # WS endpoint must come first
        get Lanes.config.api_path + '/ws' do
            API::Cable.server.call(env)
        end


        Extensions.each(reversed: true) do | ext |
            ext.route(self)
        end

        put Lanes.config.api_path + '/system-settings.json',
            &SystemSettings.update_handler

        post Lanes.config.api_path + '/asset',
             &API::Handlers::Asset.saver

        get Lanes.config.api_path + '/asset/*',
            &API::Handlers::Asset.getter

        post Lanes.config.api_path + '/dev-file-change.json' do
            API::PubSub.publish("file-change", data)
            "OK"
        end
    end
end
