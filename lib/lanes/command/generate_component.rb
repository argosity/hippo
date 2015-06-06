require_relative 'model_attribute'

module Lanes
    module Command

        class GenerateComponent < NamedCommand
            OPTIONS ||= {
              namespace: nil,
            }
            class_options( OPTIONS )
            attr_reader :component_class

            def set_variables
                super
                @component_class = "#{namespace}.Components.#{class_name}"
            end

            def create_component
                template "client/components/Component.cjsx",   "#{client_dir}/components/#{class_name}.cjsx"
                template "spec/client/components/ComponentSpec.coffee", \
                         "#{spec_dir}/components/#{class_name}Spec.coffee"
            end


        end

    end
end
