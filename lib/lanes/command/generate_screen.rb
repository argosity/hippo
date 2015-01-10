require_relative 'model_attribute'

module Lanes
    module Command

        class GenerateScreen < NamedCommand
            OPTIONS = {
                title:       '',
                description: '',
                icon:        '',
                group_id:    '',
                model_class: '',
                namespace: nil
            }
            class_options( OPTIONS )

            def set_defaults
                options[:title] = name.titleize if options[:title].blank?
            end

            def create_screen
                template "client/screens/index.js",      "#{client_dir}/screens/#{name}/index.js"
                template "client/screens/styles.scss",   "#{client_dir}/screens/#{name}/index.scss"
                template "client/screens/Screen.coffee",
                         "#{client_dir}/screens/#{name}/#{class_name}.coffee"
                template "client/screens/layout.html",   "#{client_dir}/screens/#{name}/layout.html"
                template "spec/client/Screen.coffee",    "#{spec_dir}/screens/#{class_name}.coffee"
            end

            def add_definition
                insert_into_file "config/screens.rb", after: "" do
                    source = File.expand_path(find_in_source_paths("config/screen.rb"))
                    ERB.new(::File.binread(source), nil, "-","@output_buffer").result(binding)
                end

            end
        end
    end
end
