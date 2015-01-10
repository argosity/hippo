module Lanes

    module Components
        @@enabled = []

        class << self

            # @param names [Symbol] list of components to include in applications
            def enable(*names)
                @@enabled += names.map(&:to_sym)
                @@enabled.uniq!
            end

            def enabled(&block)
                @@enabled.each{ |component| yield component }
            end

            # Called by sprockets during processing from the client/components/enabled.js.erb
            # Requires the enabled components and all of their dependencies
            def enabled_with_dependencies(env, &block)
                enabled do | component |
                    config = component_configuration(component, env.environment)
                    if config['depends']
                        config['depends'].each{ |d| yield d }
                    end
                    yield component
                end
            end

            # @param component [String,Symbol] component name to lookup
            # @return Hash configuration for component, read from a config.json file in the components directory,
            # or an empty hash if no configuration is present
            def component_configuration(component, env)
                if asset = env.find_asset("lanes/components/#{component}")
                    config_file = asset.pathname.dirname.join("config.json")
                    if config_file.exist?
                        return Oj.load(config_file.read)
                    end
                end
                return {}
            end

        end
    end

end
