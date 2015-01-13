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
                template "client/views/View.coffee",   "#{client_dir}/#{name.classify}.coffee"
                template "spec/client/views/ViewSpec.coffee", \
                  "#{spec_dir}/views/#{class_name}Spec.coffee"
            end

          private

            def client_dir
                if options[:screen] == 'global'
                    "client/#{namespace}/views"
                else
                    "client/#{namespace}/screens/#{options[:screen].dasherize}"
                end
            end
        end

    end
end
