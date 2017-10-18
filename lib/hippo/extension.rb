module Hippo

    module Extensions

        ALL=Array.new

        class << self
            include Enumerable

            def load_screens
                each do | ext |
                    screens_config = ext.root_path.join('config','screens.rb')
                    if screens_config.exist?
                        require screens_config
                    end
                end
            end

            def add(klass)
                @cached_instances = nil
                ALL << klass
            end

            def all
                ALL
            end

            def for_identifier(identifier)
                each{|ext| return ext if ext.identifier == identifier }
                nil
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
                        Hippo.logger.info "Conflicting load directives.  Some extensions will not be available"
                    end
                    unmapped -= mapped
                end
                mapped
            end

            def each(reversed: false)
                @cached_instances ||= sorted.map{ |klass| klass.new }
                (reversed ? @cached_instances.reverse : @cached_instances).each do |ext|
                    yield ext
                end
            end

            def controlling
                last = ALL.last
                each{|ext| return ext if ext.is_a?(last) }
                Hippo.logger.error "Unable to find controlling extension. #{sorted} are loaded"
            end

            # Loads the code for the extension that the user is currently
            # working inside.  The `hippo` command uses this to detect
            # what actions should be taken.
            #
            # Will silently swallow any exceptions that are raised when the file is required and return nil
            #
            # @return [Extension] extension that was loaded, nil if none was found
            def bootstrap(raise_on_fail:false)
                ext = Dir.glob("./lib/*/extension.rb").first
                if ext
                    begin
                        require(ext)
                    rescue =>e
                        stack = e.backtrace[0..4].join("\n")
                        raise Thor::Error.new("Loading ./lib/*/extension.rb failed with: #{e}\n#{stack}")
                    end
                    Extensions.controlling
                else
                    return _maybe_fail(raise_on_fail)
                end
            end

            def _maybe_fail(should_raise)
                raise Thor::Error.new("Unable to locate Hippo environment.\nDoes ./lib/*/extension.rb exist?") if should_raise
                return nil
            end

            ## Data returned will be included in the JS build;
            ## it should not be Tenant specific
            def client_bootstrap_data
                data = {}
                %w{
                  api_path environment website_domain product_name assets_path_prefix
                }.each do |config|
                    data[config.to_sym] = Hippo.config.send(config)
                end
                data.merge!(
                    controlling_extension: controlling.identifier,
                )
                each do | ext |
                    ext_data  = ext.client_bootstrap_data
                    data[ext.identifier] = ext_data unless ext_data.nil?
                end
                data[:screen_ids] = Hippo::Screen.active_ids
                return data
            end

            def load_controlling_config
                config_file = self.controlling.root_path.join('config','initialize.rb')
                if config_file.exist?
                    require config_file
                end
            end

            def client_module_paths
                map { |e| e.root_path.join('client').to_s }.reverse + [
                    controlling.root_path.join('node_modules').to_s
                ]
            end

        end

    end

end

require_relative 'extension/definition'
