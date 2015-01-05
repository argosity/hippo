require_relative 'model_attribute'

module Lanes
    module Command

        class GenerateView < NamedCommand
            OPTIONS ||= {
              namespace: nil,
              screen: 'global'
            }
            class_options( OPTIONS )

            # desc "foo bar"
            # option :from, :required => true

            def create_screen
                template "client/views/View.coffee",   "#{client_dir}/views/#{name.classify}.coffee"
                #template "client/views/template.html", "#{client_dir}/views/#{name.dasherize}.html"
                template "spec/client/views/ViewSpec.coffee", \
                  "#{spec_dir}/views/#{class_name}Spec.coffee"
            end

          private

            def client_dir
                if options[:screen] == 'global'
                    "client/views"
                else
                    "client/screens/#{options[:screen].dasherize}"
                end
            end
        end

    end
end
