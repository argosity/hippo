require_relative 'model_attribute'

module Lanes
    module Command

        class GenerateView < NamedCommand
            OPTIONS ||= {
                namespace: nil
            }
            class_options( OPTIONS )

            def create_screen
                template "client/views/View.coffee",   "#{client_dir}/views/#{name.classify}.coffee"
                template "client/views/template.html", "#{client_dir}/views/#{name.dasherize}.html"
                template "spec/client/views/ViewSpec.coffee", \
                         "spec/client/views/#{class_name}Spec.coffee"
            end

        end

    end
end
