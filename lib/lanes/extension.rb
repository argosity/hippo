module Lanes

    module Extensions

        class Definition
            include Concerns::AttrAccessorWithDefault

            attr_reader :context

            attr_accessor_with_default :load_phase, :late

            attr_accessor_with_default :identifier

            # Array of Pathname's to add to sprockets
            attr_accessor_with_default :root_path

            # Load extension before/after the named extensions
            class_attribute :before
            class_attribute :after

            def self.components(*names)
                Components.enable(*names)
            end

            def client_bootstrap_data(view)
                {}
            end

            def javascript_include
                self.identifier + "-extension.js"
            end

            def client_namespace
                identifier.underscore.camelize
            end

            def client_paths
                [ self.root_path.join("client") ]
            end

            def route(route_set)
                routes_config = root_path.join('config','routes.rb')
                if routes_config.exist?
                    require routes_config
                end
            end
        end

        class << self

            def load_after(extension)
                self.after = extension
            end

            def load_before(extension)
                self.before = extension
            end

            def all
                Definition.descendants
            end

            def sorted
                unmapped = all
                mapped   = []
                while unmapped.any?
                    mapped_count = mapped.length
                    unmapped.each do | ext |
                        if !ext.before && !ext.after
                            mapped.push(ext)
                        end
                        if ext.before && (position = mapped.find_index(ext.before))
                            mapped.insert(position, ext)
                        end
                        if ext.after && (position = mapped.find_index(ext.after))
                            mapped.insert(position+1, ext)
                        end
                    end
                    if mapped_count == mapped.length # we failed to add any extensions
                        Lanes.logger.info "Conflicting load directives.  Some extensions will not be available"
                    end
                    unmapped -= mapped
                end
                mapped
            end

            def each
                sorted.map{ |klass| yield klass.new }
            end

            def early_loaded
                each{ |ext| yield ext if ext.load_phase == :early }
            end

            def late_loaded
                each{ |ext| yield ext if ext.load_phase == :late  }
            end

            def client_bootstrap_data(view)
                data = {}
                each do | ext |
                    data[ext.identifier] = ext.client_bootstrap_data(view)
                end
                return data
            end


            def load_current_config
                config_file = Pathname.getwd.join('config','lanes.rb')
                if config_file.exist?
                    require config_file
                end
            end

        end

    end
end
