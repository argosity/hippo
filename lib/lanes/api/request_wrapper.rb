module Lanes
    module API

        module RequestWrapper
            class << self

                def get(*args)
                    make_handler(*args) do |controller|
                        controller.perform_retrieval
                    end
                end

                def post(*args)
                    make_handler(*args) do |controller|
                        controller.perform_creation
                    end
                end

                def update(*args)
                    make_handler(*args) do |controller|
                        controller.perform_update
                    end
                end

                def delete(*args)
                    make_handler(*args) do |controller|
                        controller.perform_destroy
                    end
                end

                def make_handler(model, controller, parent_attribute)
                    lambda do
                        authentication = Lanes::API::AuthenticationProvider.new(
                          request_type: request.request_method,
                          session:      session,
                          params:       params
                        )
                        authentication.wrap_reply(model,self) do
                            if parent_attribute
                              params[:nested_attribute] = Hash[ parent_attribute,
                                                               params[parent_attribute] ]
                            end
                            wrap_reply(!request.get?) do
                                yield controller.new(model, authentication, params, data)
                            end
                        end
                    end
                end
            end

            def log_request
                Lanes.logger.info "UserID: #{session['user_id']}, Params: #{request.params}"
            end

            def wrap_reply(with_transaction=true)
                response = { success: false, message: "No response was generated" }
                log_request
                if with_transaction
                    Lanes::Model.transaction do
                         response = yield
                        # This is quite possibly a horrible idea.
                        # It enables test specs to reset the db state after a request
                        if Lanes.env.test? && request.env['HTTP_X_ROLLBACK_AFTER_REQUEST']
                            Lanes::Model.connection.rollback_db_transaction
                        end
                    end
                else
                    response = yield
                end
                if false == response[:success]
                    status(406)
                end
                content_type 'application/json'
                Oj.dump(response, mode: :compat)
            end

        end


    end
end
