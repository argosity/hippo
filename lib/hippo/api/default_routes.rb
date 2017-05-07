require_relative "handlers/asset.rb"

module Hippo
    API.routes.draw do
        # WS endpoint must come first
        get Hippo.config.api_path + '/ws' do
            API::Cable.handle_request(request)
        end

        Extensions.each(reversed: true) do | ext |
            ext.route(self)
        end

        put Hippo.config.api_path + '/hippo/system-settings.json',
            &SystemSettings.update_handler

        get Hippo.config.api_path + '/hippo/system-settings.json',
            &SystemSettings.get_handler

        post Hippo.config.api_path + Hippo.config.assets_path_prefix,
             &API::Handlers::Asset.saver

        get Hippo.config.api_path + Hippo.config.assets_path_prefix + '/*',
            &API::Handlers::Asset.getter

        get Hippo.config.api_path + Hippo.config.print_path_prefix + '/:template_id/:model_id.pdf',
            &API::Handlers::Print.getter

        post Hippo.config.api_path + '/dev-file-change.json' do
            API::PubSub.publish("file-change", data)
            "OK"
        end

    end

    # API.set_root_view :hippo_root_view

end
