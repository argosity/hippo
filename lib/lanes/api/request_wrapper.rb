module Lanes
    module API

        module RequestWrapper
            class << self

                def get(*args)
                    wrap_request(*args) do |controller|
                        controller.perform_retrieval
                    end
                end

                def post(*args)
                    wrap_request(*args) do |controller|
                        controller.perform_creation
                    end
                end

                def update(*args)
                    wrap_request(*args) do |controller|
                        controller.perform_update
                    end
                end

                def delete(*args)
                    wrap_request(*args) do |controller|
                        controller.perform_destroy
                    end
                end

                def wrap_request(model, controller, parent_attribute)
                    lambda do
                        authentication = Lanes::API::AuthenticationProvider.new(
                          request_type: request.request_method,
                          session:      session,
                          params:       params
                        )
                        authentication.wrap_request(model,self) do
                            if parent_attribute
                              params[:nested_attribute] = Hash[ parent_attribute,
                                                               params[parent_attribute] ]
                            end
                            wrap_json_reply do
                                yield controller.new(model, authentication, params, data)
                            end
                        end
                    end
                end
            end

            def wrap_json_reply
                response = yield
                if false == response[:success]
                    status(406)
                end
                content_type 'application/json'
                Oj.dump(response, mode: :compat)
            end

        end


    end
end
