module Hippo
    module API

        module RequestWrapper
            class << self

                def get(*args)
                    make_handler(*args) do |controller|
                        controller.show
                    end
                end

                def post(*args)
                    make_handler(*args) do |controller|
                        controller.create
                    end
                end

                def update(*args)
                    make_handler(*args) do |controller|
                        controller.update
                    end
                end

                def delete(*args)
                    make_handler(*args) do |controller|
                        controller.destroy
                    end
                end

                # @!visibility private
                def make_handler(model, controller, options = {})
                    lambda do
                        authentication = Hippo::API::AuthenticationProvider.new(request)
                        authentication.wrap_model_access(model, self, options) do
                            if options[:parent_attribute]
                              params[:nested_attribute] = Hash[ options[:parent_attribute],
                                                               params[parent_attribute] ]
                            end
                            wrap_reply(options.reverse_merge(with_transaction: !request.get?)) do
                                yield controller.new(model, authentication, params, data)
                            end
                        end
                    end
                end


                # Ensure request is performed with a logged in user. The provided block will be called
                # with |user, request|
                #
                # @param [options] options for additional checks
                # @option options [String] :role A role name that the user must have
                # @option opts [Boolean] :with_transaction rollback DB transaction if exceptions occur
                #
                def with_authenticated_user(options = {with_transaction: true})
                    role = options[:role]
                    lambda do
                        authentication = Hippo::API::AuthenticationProvider.new(request)
                        user = authentication.current_user
                        if user && (role.nil? || user.roles.include?(role))
                            wrap_reply(options) do
                                yield authentication.current_user, self
                            end
                        else
                            authentication.fail_request(self)
                        end
                    end
                end
            end

            # Wraps a HTTP request in an optional DB transaction and converts yeilded data to JSON
            #
            # @param [options] options for additional checks
            # @option opts [Boolean] :with_transaction rollback DB transaction if exceptions occur
            # @option opts [Boolean] :require_tenant return error if tenant is not found
            def wrap_reply(options = { with_transaction: true, require_tenant: true })
                if options[:require_tenant] && Hippo::Tenant.current.nil?
                    return json_reply(
                               { success: false, message: "invalid address",
                                 errors: { address: 'invalid' } }
                           )
                end
                response = { success: false, message: "No response was generated" }
                log_request
                if options[:with_transaction]
                    Hippo::Model.transaction do
                        response = yield || {success: false}
                        # This is quite possibly a horrible idea.
                        # It enables test specs to reset the db state after a request
                        if !Hippo.env.production? && request.env['HTTP_X_ROLLBACK_AFTER_REQUEST']
                            Hippo::Model.connection.rollback_db_transaction
                        end
                    end
                else
                    response = yield
                end
                if false == response[:success]
                    status(406)
                end
                json_reply response
            end

            # Logs UserID and params for a request.  In non-production, the JSON payload is also logged
            def log_request
                Hippo.logger.info "UserID: #{session['user_id']}, Params: #{request.params}"
                Hippo.logger.debug JSON.pretty_generate(data) unless Hippo.env.production? or data.nil?
            end
        end


    end
end
