module Lanes
    module API
        module HelperMethods
            def lanes_application_title
                Extensions.controlling.title
            end

            def lanes_javascript_tags
                javascript_tag('lanes/vendor') + "\n" + javascript_tag('lanes')
            end

            def lanes_stylesheet_tags
                stylesheet_tag('lanes')
            end

            def client_bootstrap_data(mergedWith: {})
                API.to_json(Extensions.client_bootstrap_data(self).merge(mergedWith))
            end

            def csrf_token
                Rack::Csrf.csrf_token(env)
            end

            def lanes_api_url
                Lanes.config.api_path
            end

            def error_as_json
                Lanes.logger.warn request.env['sinatra.error']
                API.to_json(
                    success: false,
                    errors:  { exception: request.env['sinatra.error'].message },
                    message: request.env['sinatra.error'].message
                )
            end

            def data
                @json_data ||= Oj.load( request.body.read )
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
