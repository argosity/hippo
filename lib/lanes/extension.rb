module Lanes

    class Extension
        include Concerns::AttrAccessorWithDefault

        attr_reader :context

        attr_accessor_with_default :identifier

        # Array of Pathname's to add to sprockets
        attr_accessor_with_default :root_path

        # Load extension before/after the named extensions
        class_attribute :before
        class_attribute :after

        def bootstrap_data(view)
            {}
        end

        def initialize(context)
            @context = context
        end

        def javascript_include
            self.identifier + ".js"
        end

        def client_paths
            client = self.root_path.join("client")
            client.entries.select{ |path|
                !path.to_s.start_with?(".")
            }.map{ |path| client.join(path).expand_path }
        end

        class << self

            def load_after(extension)
                self.after = extension
            end

            def load_before(extension)
                self.before = extension
            end

            def active
                unmapped = self.descendants
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

            def each(context={})
                self.active.each{ |klass| yield klass.new(context) }
            end

            def bootstrap_data(context)
                data = { 'roles' => Lanes::Access::Role.all_available }
                each do | ext |
                    data[ext.identifier] = ext.bootstrap_data(context)
                end
                return data
            end
        end

    end
end
