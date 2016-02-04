module Lanes
    API.routes.draw do

        put Lanes.config.api_path + 'system-settings.json',
            &SystemSettings.update_handler

        post Lanes.config.api_path + 'save-file-attribute',
             &API::Handlers::File.saver

        get Lanes.config.api_path + 'file/*',
            &API::Handlers::File.getter

        Extensions.each(reversed: true) do | ext |
            ext.route(self)
        end

    end
end
