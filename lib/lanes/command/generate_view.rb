require_relative 'model_attribute'

module Lanes
    module Command

        class GenerateView < NamedCommand
            OPTIONS ||= {
              namespace: nil,
              screen: 'global'
            }
            class_options( OPTIONS )

            def set_variables
                super
                if options[:screen] == 'global'
                    @client_dir << "/views"
                    @spec_dir   << "/views"
                else
                    @client_dir << "/screens/#{options[:screen].underscore.dasherize}"
                    @spec_dir   << "/screens/#{options[:screen].underscore.dasherize}"
                end
            end

            # desc "foo bar"
            # option :from, :required => true

            def create_screen
                template "client/views/View.coffee",   "#{client_dir}/#{name.classify}.coffee"
                template "spec/client/views/ViewSpec.coffee", \
                  "#{spec_dir}/#{class_name}Spec.coffee"
            end


        end

    end
end
