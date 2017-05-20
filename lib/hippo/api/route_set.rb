module Hippo
    module API

        class RoutingBlock
            def initialize(ext_id)
                Hippo::Extensions.for_identifier(ext_id) ||
                    raise( "Unable to find extension '#{ext_id}' for screen group")
                @ext_id = ext_id
            end

            [:get, :post, :put, :patch, :delete].each do | method_name |
                define_method(method_name) do | path_suffix, options = {}, &block |
                    API::Root.send(method_name, make_path(path_suffix), options, &block)
                end
            end

            def enable_cors(path_suffix, options = {origins: '*', methods: [:get]})
                API::Root::CORS_PATHS[make_path(path_suffix)] = options
            end

            def resources(model, options = {})
                path = options[:path] || model.api_path
                controller = options[:controller] || Hippo::API::GenericController
                format = options[:format] || '.json'
                if options[:under]
                    options[:parent_attribute] = options[:under].underscore.singularize+'_id'
                end

                prefix = options[:parent_attribute] ? options[:parent_attribute] + '/' : ''

                valid_methods = []

                bind = lambda{ |method, route, wrapper_method = method|
                    valid_methods.push(method)
                    self.send(method, route + format,
                              &RequestWrapper.send(wrapper_method, model, controller, options))
                }

                # show
                if controller.method_defined?(:show)
                    bind[:get, "#{prefix}#{path}/?:id?"]
                end

                # create
                if controller.method_defined?(:create)
                    bind[:post, "#{prefix}#{path}"]
                end

                unless options[:immutable]

                    # update
                    if controller.method_defined?(:update)
                        bind[:patch, "#{prefix}#{path}/?:id?", :update]
                        bind[:put,   "#{prefix}#{path}/?:id?", :update]
                    end

                    # destroy
                    if controller.method_defined?(:destroy) and not options[:indestructible]
                        bind[:delete, "#{prefix}#{path}/?:id?"]
                    end

                end

                if options[:cors] && valid_methods.any?
                    cors = options[:cors].is_a?(Hash) ? otions[:cors] : {origins: options[:cors]}
                    enable_cors "#{prefix}#{path}/?:id?#{format}",
                                cors.merge(methods: valid_methods)
                end

            end

            private

            def make_path(path)
                path = Hippo.config.api_path + '/' + @ext_id + '/' + path
                Hippo.logger.debug("[route]: #{path}")
                path
            end
        end

        class RouteSet
            def initialize(root)
                @root = root
            end

            def draw(&block)
                @root.instance_eval(&block)
            end

            def for_extension(ext_id, &block)
                routes = RoutingBlock.new(ext_id)
                routes.instance_eval(&block)
            end
        end

        def self.routes(&block)
            @routes ||= RouteSet.new(API::Root)
        end

    end
end
