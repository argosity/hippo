module Lanes
    module Extensions

        class Definition
            include ::Lanes::Concerns::AttrAccessorWithDefault

            def self.inherited(klass)
                Extensions.add(klass)
            end

            attr_reader :context

            attr_accessor_with_default :client_js_aliases, lambda{ Hash.new }

            attr_accessor_with_default :title, ''

            attr_accessor_with_default :load_phase, :late

            attr_accessor_with_default :identifier

            # Array of Pathname's to add to sprockets
            attr_accessor_with_default :root_path

            attr_accessor_with_default :db_table_prefix

            # Load extension before/after the named extensions
            class_attribute :before
            class_attribute :after

            def self.components(*names)
                Components.enable(*names)
            end

            def initialize
                self.add_to_load_path
            end

            def load_after(extension)
                self.after = extension
            end

            def load_before(extension)
                self.before = extension
            end

            def client_bootstrap_data
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

            def standard_client_path
                root_path.join('client', identifier )
            end

            def static_paths
                client_paths.each_with_object(Array.new) do |path, result|
                    Lanes.config.static_asset_types.each do | prefix |
                        result << path.join(prefix) if path.join(prefix).exist?
                    end
                end
            end

            def each_static_asset
                static_paths.each do | path |
                    path.find.each do | entry |
                        yield entry.relative_path_from(path) if entry.file?
                    end
                end
            end

            def route(route_set)
                routes_config = root_path.join('config','routes.rb')
                if routes_config.exist?
                    require routes_config
                end
            end

            def on_boot
            end

            def add_to_load_path
                @in_load_path_set ||= (
                    lib = root_path.join('lib').to_s
                    $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
                )
            end

            def apply_configuration
                 config_file = root_path.join('config', 'lanes.rb')
                 if config_file.exist?
                     require config_file
                 end
            end
        end

        class Base < Definition
            identifier "lanes"
            title "Lanes Application"
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

require_relative("../access/extension")
require_relative("../workspace/extension")
