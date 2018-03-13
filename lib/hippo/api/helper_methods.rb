module Hippo
    module API
        module HelperMethods
            def hippo_application_title
                Extensions.controlling.title
            end

            def javascript_tag(tag, options = {})
                Root.webpack.wait_until_available
                opts = []
                opts.push('crossorigin') unless Hippo.env.production?
                opts.push('async') unless options[:async] == false
                "<script #{opts.join(' ')} src=\"#{Root.webpack.host}/assets/#{Root.webpack.file(tag)}\"></script>"
            end

            def csrf_token
                Rack::Csrf.csrf_token(env)
            end

            def hippo_api_url
                Hippo.config.api_path
            end

            def error_as_json
                error = request.env['sinatra.error']
                Hippo.logger.warn error.message
                Hippo.logger.warn error.backtrace.join("\n    ")
                API.to_json(
                    success: false,
                    errors:  { exception: error.message },
                    message: error.message
                )
            end

            def data
                if request.content_type == 'application/json'
                    @json_data ||= (
                        body = request.body.read
                        body.present? ? Oj.load(body) : {}
                    )
                else
                    request.params
                end
            end

            def request_origin
                @request_origin ||= env['HTTP_ORIGIN']
            end

            def json_reply(response)
                content_type 'application/json'
                API.to_json(response)
            end

            def find_template(views, name, engine, &block)
                views.each{ |v| super(v, name, engine, &block) }
            end
        end
    end
end
