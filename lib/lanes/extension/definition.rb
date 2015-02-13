module Lanes
    module Extensions

        class Definition
            include ::Lanes::Concerns::AttrAccessorWithDefault

            def self.inherited(klass)
                if Extensions.controlling_locked
                    ALL.unshift(klass)
                else
                    ALL << klass
                end
            end

            attr_reader :context

            attr_accessor_with_default :load_phase, :late

            attr_accessor_with_default :identifier

            # Array of Pathname's to add to sprockets
            attr_accessor_with_default :root_path

            # Does the extension use PubSub functionality
            class_attribute  :uses_pub_sub

            # Load extension before/after the named extensions
            class_attribute :before
            class_attribute :after

            def self.components(*names)
                Components.enable(*names)
            end

            def client_bootstrap_data(view)
                {}
            end

            def stylesheet_include
                self.identifier + '/styles'
            end

            def javascript_include
                self.identifier
            end

            def client_namespace
                identifier.underscore.camelize
            end

            def client_paths
                [ root_path.join('client') ]
            end

            def client_images
                images = []
                root_path.join('client','images').find{|path| images << path if path.file? }
                images
            end

            def route(route_set)
                routes_config = root_path.join('config','routes.rb')
                if routes_config.exist?
                    require routes_config
                end
            end

            def on_boot
            end

        end

        class Base < Definition
            identifier "lanes"

            root_path Pathname.new(__FILE__).dirname.join("..","..","..").expand_path
            def stylesheet_include
                nil
            end

            def javascript_include
                nil
            end

            def on_boot
                if Lanes.env.test? && Extensions.controlling.class == self.class
                    Extensions.lock_controlling!
                    require_relative("../workspace/extension")
                end
            end

        end

    end
end
