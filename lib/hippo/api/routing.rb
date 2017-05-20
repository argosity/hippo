module Hippo
    module API

        module Routing
            mattr_accessor :root_view_route

            API.routes.draw do
                # WS endpoint must come first
                get Hippo.config.api_path + '/ws' do
                    API::Cable.handle_request(request)
                end

                Extensions.each(reversed: true) do | ext |
                    ext.route(self)
                end
            end

            root_view_route.call if root_view_route
        end

    end
end
