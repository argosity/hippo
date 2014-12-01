require_relative 'model_attribute'

module Lanes
    module Command

        class GenerateView < Thor::Group
            include Thor::Actions
            OPTIONS = {
                namespace: nil
            }
            argument :name
            attr_reader :namespace, :class_name
            class_options( OPTIONS )

            def self.source_root
                Pathname.new(__FILE__).dirname.join("templates")
            end

            def load_extension
                @namespace  = options[:namespace] || Command.load_current_extension.identifier
                @class_name = name.camelize
            end

            def create_screen
                template "client/views/View.coffee",   "client/views/#{name.classify}.coffee"
                template "client/views/template.html", "client/views/#{name.dasherize}.html"
                template "spec/client/views/ViewSpec.coffee", \
                         "spec/client/views/#{class_name}Spec.coffee"
            end

        end

    end
end
