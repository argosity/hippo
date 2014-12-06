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
                template "lib/namespace/screen.rb",      "lib/#{namespace}/#{name}_screen.rb"
                template "client/screens/index.js",      "#{client_dir}/screens/#{name}/index.js"
                template "client/screens/styles.scss",   "#{client_dir}/screens/#{name}/index.scss"
                template "client/screens/Screen.coffee", "#{client_dir}/screens/#{name}/#{name.classify}.coffee"
                template "client/screens/layout.html",   "#{client_dir}/screens/#{name}/layout.html"
            end

        end
    end
end
