module Hippo
    module API
        module HelperMethods
            def hippo_application_title
                Extensions.controlling.title
            end

            def hippo_javascript_tags
                []
                # assets = API.webpack.assets.map do | k |
                #     "<script src=\"http://localhost:#{API.webpack.port}/#{k}\"></script>"
                # end
                # assets.join("\n")

                # "<script src=\"http://localhost:#{API.webpack.port}/hippo.js\"></script>"
                # javascript_tag('hippo/vendor') + "\n" + javascript_tag('hippo')
            end

            def hippo_stylesheet_tags
                # stylesheet_tag('hippo')
            end

            def client_bootstrap_data(mergedWith: {})
                API.to_json(Extensions.client_bootstrap_data.merge(mergedWith))
            end

            def csrf_token
                Rack::Csrf.csrf_token(env)
            end

            def hippo_api_url
                Hippo.config.api_path
            end

            def error_as_json
                Hippo.logger.warn request.env['sinatra.error']
                API.to_json(
                    success: false,
                    errors:  { exception: request.env['sinatra.error'].message },
                    message: request.env['sinatra.error'].message
                )
            end

            def data
                @json_data ||= Oj.load( request.body.read ) || {}
            end

            def request_origin
                @request_origin ||= env['HTTP_ORIGIN']
            end

            def json_reply(response)
                content_type 'application/json'
                API.to_json(response)
            end
        end
    end
end
