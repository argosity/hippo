require_relative 'model_attribute'

module Lanes
    module Command

        class GenerateScreen < Thor::Group
            include Thor::Actions
            OPTIONS = {
                title:       '',
                description: '',
                icon:        '',
                group_id:    '',
                model_class: '',
                namespace: nil
            }
            argument :name
            attr_reader :namespace, :class_name
            class_options( OPTIONS )

            def self.source_root
                Pathname.new(__FILE__).dirname.join("templates")
            end

            def set_defaults
                options[:title] = name.titleize if options[:title].blank?
            end

            def load_extension
                @namespace  = options[:namespace] || Command.load_current_extension.identifier
                @class_name = name.camelize
            end

            def create_screen
                template "lib/namespace/screen.rb",      "lib/#{namespace}/#{name}_screen.rb"
                template "client/screens/index.js",      "client/screens/#{name}.js"
                template "client/screens/styles.scss",   "client/screens/#{name}.scss"
                template "client/screens/Screen.coffee", "client/screens/#{name.classify}.coffee"
                template "client/screens/template.html", "client/screens/#{name.dasherize}-layout.html"
            end

        end
    end
end
