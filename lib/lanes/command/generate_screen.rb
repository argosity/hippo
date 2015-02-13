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

            attr_reader :screen_id

            def set_variables
                super
                options[:title] = name.titleize if options[:title].blank?
                @screen_id = class_name.underscore.dasherize
            end

            def create_screen
                template "client/screens/index.js",      "#{client_dir}/screens/#{screen_id}/index.js"
                template "client/screens/styles.scss",   "#{client_dir}/screens/#{screen_id}/index.scss"
                template "client/screens/Screen.coffee", "#{client_dir}/screens/#{screen_id}/#{class_name}.coffee"
                template "client/screens/layout.html",   "#{client_dir}/screens/#{screen_id}/layout.html"
                template "spec/client/Screen.coffee",    "#{spec_dir}/screens/#{screen_id}/#{class_name}Spec.coffee"
            end

            def add_definition
                append_to_file "config/screens.rb" do
                    source = File.expand_path(find_in_source_paths("config/screen.rb"))
                    ERB.new(::File.binread(source), nil, "-","@output_buffer").result(binding)
                end
            end
        end
    end
end
