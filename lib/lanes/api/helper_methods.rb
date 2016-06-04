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

            def client_bootstrap_data
                Oj.dump(Extensions.client_bootstrap_data(self), mode: :compat)
            end

            def csrf_token
                Rack::Csrf.csrf_token(env)
            end

            def lanes_api_url
                Lanes.config.api_path
            end

            def error_as_json
                Lanes.logger.warn request.env['sinatra.error']
                Oj.dump({
                    success: false,
                    errors:  { exception: request.env['sinatra.error'].message },
                    message: request.env['sinatra.error'].message
                }, mode: :compat)
            end

            def data
                @json_data ||= Oj.load( request.body.read )
            end

            def request_origin
                @request_origin ||= env['HTTP_ORIGIN']
            end

            def json_reply( response )
                content_type 'application/json'
                Oj.dump(response, mode: :compat)
            end


        end

    end
end
