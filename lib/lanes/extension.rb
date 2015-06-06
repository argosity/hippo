module Lanes

    module Extensions
        mattr_accessor :controlling_locked

        ALL=Array.new

        class << self

            def load_screens
                each do | ext |
                    screens_config = ext.root_path.join('config','screens.rb')
                    if screens_config.exist?
                        require screens_config
                    end
                end
            end

            # lock the current controlling extension so that it can't
            # be changed by other extensions that are loaded later
            def lock_controlling!
                self.controlling_locked=true
            end

            def add(klass)
                @cached_instances = nil
                if Extensions.controlling_locked
                    ALL.unshift(klass)
                else
                    ALL << klass
                end
            end

            def all
                ALL
            end

            def each_asset(phase: :early, type: :js)
                each do |ext|
                    if phase == :all || ext.load_phase == phase
                        asset = case type
                                when :js  then ext.javascript_include
                                when :css then ext.stylesheet_include
                                else nil
                                end
                        yield asset unless asset.nil?
                    end
                end
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
                @cached_instances ||= sorted.map{ |klass| klass.new }
                @cached_instances.each{ |ext| yield ext }
            end

            def controlling
                last = ALL.last
                each{|ext| return ext if ext.is_a?(last) }
                Lanes.logger.error "Unable to find controlling extension. #{sorted} are loaded"
            end

            def client_bootstrap_data(view)
                data = {
                  csrf_token: Rack::Csrf.csrf_token(view.env),
                  controlling_extension: controlling.identifier,
                  root_view:  Lanes.config.root_view,
                  assets_path_prefix: Lanes.config.assets_path_prefix,
                  api_path: Lanes.config.mounted_at,
                  environment: Lanes.config.environment,
                  initial_workspace_screen_id: Lanes.config.initial_workspace_screen_id,
                }
                each do | ext |
                    ext_data  = ext.client_bootstrap_data(view)
                    data[ext.identifier] = ext_data unless ext_data.nil?
                end
                return data
            end

            def load_controlling_config
                config_file = self.controlling.root_path.join('config','lanes.rb')
                if config_file.exist?
                    require config_file
                end
            end

        end

    end


end

require_relative 'extension/definition'
