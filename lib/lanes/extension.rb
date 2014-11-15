module Lanes

    class Extension

        def initialize(*args)
        end

        class_attribute :identifier

        # [String] The path for including the extension in the asset pipeline
        class_attribute :logical_path


        # [String] The directory that holds the the root of the asset pipeline
        class_attribute :asset_path

        class_attribute :before
        class_attribute :after

        def bootstrap_data(view)
            {}
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

            def each(config={})
                self.active.each{ |klass| yield klass.new(config) }
            end

            def bootstrap_data(env)
                data = { 'roles' => Lanes::Access::Role.all_available }
                each do | ext |
                    data[ext.identifier] = data.bootstrap_data(env)
                end
                return data
            end
        end

    end
end
