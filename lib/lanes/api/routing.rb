module Lanes
    module API

        class RoutingBlock
            def initialize(ext_id)
                Lanes::Extensions.for_identifier(ext_id) ||
                    raise( "Unable to find extension '#{ext_id}' for screen group")
                @ext_id = ext_id
            end

            def root_view( view )
                API::Root.get Lanes.config.mounted_at + '?*' do
                    pass unless request.accept? 'text/html'
                    erb view
                end
            end

            [:get, :post, :put, :patch, :delete].each do | method_name |
                define_method(method_name) do | path, options = {}, &block |
                    API::Root.send(method_name, make_path(path), options, &block)
                end
            end

            def resources(model, options = {})
                path = options[:path] || model.api_path
                controller = options[:controller] || Lanes::API::Controller
                parent_attribute = false
                if options[:under]
                    parent_attribute = options[:parent_attribute] || options[:under].underscore.singularize+'_id'
                end

                prefix = parent_attribute ? parent_attribute + '/' : ''

                # index
                if controller.method_defined?(:perform_retrieval)
                    get "#{prefix}#{path}/?:id?.json",
                        &RequestWrapper.get(model, controller, parent_attribute)
                end

                # create
                if controller.method_defined?(:perform_creation)
                    post "#{prefix}#{path}.json",
                         &RequestWrapper.post(model, controller, parent_attribute)
                end

                unless options[:immutable]

                    # update
                    if controller.method_defined?(:perform_update)
                        patch "#{prefix}#{path}/?:id?.json",
                              &RequestWrapper.update(model, controller, parent_attribute)
                        put   "#{prefix}#{path}/?:id?.json",
                              &RequestWrapper.update(model, controller, parent_attribute)
                    end

                    if controller.method_defined?(:perform_destroy) and not options[:indestructible]
                        # destroy
                        delete "#{prefix}#{path}/?:id?.json",
                               &RequestWrapper.delete(model, controller, parent_attribute)
                    end

                end

            end

            private

            def make_path(path)
                Lanes.config.api_path + '/' + @ext_id + '/' + path
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
