require_relative 'model_attribute'

module Lanes
    module Command

        class GenerateScreen < NamedCommand
            OPTIONS = {
                title:       '',
                description: '',
                icon:        '',
                group_id:    'system',
                model_class: '',
                namespace: nil
            }
            class_options( OPTIONS )

            attr_reader :screen_id, :screen_class

            def set_variables
                super
                options[:title] = name.titleize if options[:title].blank?
                @screen_id = class_name.underscore.dasherize
                @screen_class = "#{namespace}.Screens.#{class_name}"
            end

            def create_screen
                template "client/screens/index.js",    "#{client_dir}/screens/#{screen_id}/index.js"
                template "client/screens/styles.scss", "#{client_dir}/screens/#{screen_id}/index.scss"
                template "client/screens/Screen.cjsx", "#{client_dir}/screens/#{screen_id}/#{class_name}.cjsx"
                template "spec/client/Screen.coffee",  "#{spec_dir}/screens/#{screen_id}/#{class_name}Spec.coffee"
            end

            def add_definition
                insert_into_file "config/screens.rb", :after => /Lanes::Screen.for_extension.*?\n/ do
                    source = File.expand_path(find_in_source_paths("config/screen.rb"))
                    ERB.new(::File.binread(source), nil, "-","@output_buffer").result(binding)
                end
            end

            ROOT_EL_FUNC = /rootComponent: \(viewport\) -> null/

            def maybe_set_as_default
                path = "#{client_dir}/Extension.coffee"
                content = File.binread(path)
                return unless content.match(ROOT_EL_FUNC)
                content = "##=require ./screens/#{screen_id}\n\n" + content
                content.gsub! ROOT_EL_FUNC, <<-LOADFN.strip_heredoc.chomp
                              rootComponent: (viewport) ->
                                      # render #{screen_class} by default.  If this is changed the
                                      # ##=require ./screens/#{screen_id} at the top of file must also be updated
                                      # to ensure that the correct screen's definition will be available at boot
                                      #{screen_class}
                    LOADFN
                    File.open(path, "wb") { |file| file.write(content) }
            end
        end
    end
end
