module Lanes

    module Extensions

        ALL=Array.new

        class Definition
            include Concerns::AttrAccessorWithDefault

            def self.inherited(klass)
                ALL << klass
            end

            attr_reader :context

            attr_accessor_with_default :load_phase, :late

            attr_accessor_with_default :identifier

            # Array of Pathname's to add to sprockets
            attr_accessor_with_default :root_path

            # Does the extension use PubSub functionality
            class_attribute  :uses_pub_sub
            class_attribute  :uses_workspace

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

        end

        class LanesExtension < Definition
            identifier "lanes"

            root_path Pathname.new(__FILE__).dirname.join("..","..").expand_path
            def stylesheet_include
                nil
            end

            def javascript_include
                nil
            end

        end

        class << self

            def load_screens
                each do | ext |
                    screens_config = ext.root_path.join('config','screens.rb')
                    if screens_config.exist?
                        require screens_config
                    end
                end
            end

            def load_after(extension)
                self.after = extension
            end

            def load_before(extension)
                self.before = extension
            end

            def all
                ALL
            end

            def require_workspace?
                all.detect{|ext| ext.uses_workspace }
            end

            def require_pub_sub?
                all.detect{|ext| ext.uses_pub_sub }
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
                sorted.map{ |klass| yield klass.new }
            end

            def controlling
                last = ALL.last
                each{|ext| return ext if ext.is_a?(last) }
                LanesExtension.new # fallback if can't find an extension
            end

            def client_bootstrap_data(view)
                data = {
                  csrf_token: Rack::Csrf.csrf_token(view.env),
                  controlling_extension: controlling.identifier,
                  root_view:  Lanes.config.root_view,
                  api_path: Lanes.config.mounted_at,
                  initial_workspace_screen_id: Lanes.config.initial_workspace_screen_id,
                  pub_sub: require_pub_sub?
                }
                each do | ext |
                    data[ext.identifier] = ext.client_bootstrap_data(view)
                end
                return data
            end

            def client_images
                each{|ext| }
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
