module Lanes
    API.routes.draw do

        put Lanes.config.mounted_at + '/system-settings.json',
              &SystemSettings.update_handler

        post Lanes.config.mounted_at + '/save-file-attribute',
             &API::Handlers::File.saver

        get Lanes.config.mounted_at + '/file/*',
            &API::Handlers::File.getter


        Extensions.each(reversed: true) do | ext |
            ext.route(self)
        end

    end
end
