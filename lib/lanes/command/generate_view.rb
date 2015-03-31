require_relative 'model_attribute'

module Lanes
    module Command

        class GenerateView < NamedCommand
            OPTIONS ||= {
              namespace: nil,
              screen: 'global'
            }
            class_options( OPTIONS )
            attr_reader :view_class

            def set_variables
                super
                if options[:screen] == 'global'
                    @client_dir << "/views"
                    @spec_dir   << "/views"
                    @view_class =  "#{namespace}.Views.#{class_name}"
                else
                    screen_directory = options[:screen].underscore.dasherize
                    @client_dir << "/screens/#{screen_directory}"
                    @spec_dir   << "/screens/#{screen_directory}"
                    @view_class =  "#{namespace}.Screens.#{options[:screen]}.#{class_name}"
                end
            end

            def create_screen
                template "client/views/View.coffee",   "#{client_dir}/#{class_name}.coffee"
                template "spec/client/views/ViewSpec.coffee", \
                         "#{spec_dir}/#{class_name}Spec.coffee"
            end


        end

    end
end
