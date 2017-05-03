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

            def view_templates
                ['index.html']
            end

            def on_dev_console
            end

            def route(route_set)
                routes_config = root_path.join('config','routes.rb')
                if routes_config.exist?
                    require routes_config
                end
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

            def client_extension_path
                "#{identifier}/extension"
            end
        end

        class Base < Definition
            identifier "lanes"
            title "Lanes Application"
            root_path Pathname.new(__FILE__).dirname.join("..","..","..").expand_path

            def client_extension_path
                "lanes/extensions/lanes"
            end
        end

    end
end
