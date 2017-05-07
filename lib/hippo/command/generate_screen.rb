require_relative 'model_attribute'

module Hippo
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
                @screen_class = class_name
            end

            def create_screen
                template "client/screens/screen.jsx", "#{client_dir}/screens/#{screen_id}.jsx"
                template "spec/client/screen.spec.jsx", "spec/client/screens/#{screen_id}.spec.jsx"
            end

            def add_definition
                insert_into_file "config/screens.rb", :after => /Hippo::Screen.for_extension.*?\n/ do
                    source = File.expand_path(find_in_source_paths("config/screen.rb"))
                    ERB.new(::File.binread(source), nil, "-","@output_buffer").result(binding)
                end
            end

        end
    end
end
