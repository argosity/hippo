module Hippo
    module API
        module ErrorFormmater
            extend self

            def call(message, backtrace=nil, options=nil, env=nil)
                {
                 success: false, message: message,
                 errors: { base: message }
                }.to_json
            end

            def handle_exception(message, code, e)
                Rack::Response.new([self.call(message)],
                                   code, {"Content-type" => "application/json"}
                                  ).finish
                Hippo.logger.error e
            end

            def handle_fk_exception(e,model)
                ( target, depends ) = e.message.scan(/on table \"(.*?)\"/).flatten.map do |table|
                    table.gsub(/^hip_/, '').capitalize.singularize
                end
                Hippo::API::ErrorFormmater.handle_exception(
                  "Unable to delete #{target}, still in use by #{depends}", 400, e
                )
            end

            def handle_not_found_exception(e,model)
                Hippo::API::ErrorFormmater.handle_exception(
                  model.to_s.demodulize + " (or one of it's dependencies) was not found", 404, e
                )
            end

        end
    end
end
