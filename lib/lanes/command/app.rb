module Lanes
    module Command

        class App < NamedCommand

            class_options :force => :boolean
            class_option  :directory, type: :string
            class_option  :title,     type: :string
            attr_reader   :title

            def load_namespace # override
                @namespace  = name.underscore.camelize
                @identifier = @namespace.underscore.dasherize
            end

            def set_variables
                super
                @title = options[:title] || @namespace
                self.destination_root = options[:directory] || name
            end

            def create_files
                ["Gemfile", "Rakefile", "Guardfile", "config.ru", "config/database.yml"].each do | file |                    template file
                end
                template "lib/namespace.rb", "lib/#{identifier}.rb"
                template "lib/namespace/version.rb", "lib/#{identifier}/version.rb"
                template "lib/namespace/extension.rb", "lib/#{identifier}/extension.rb"
                template "lib/namespace/base_model.rb", "lib/#{identifier}/model.rb"
                template "../coffeelint.json", "coffeelint.json"
                template "../.rubocop.yml", ".rubocop.yml"
                template "config/screens.rb"
                template "config/routes.rb"
                template "config/lanes.rb"
                template "gitignore",".gitignore"

                create_file "log/.gitkeep",""
                create_file "tmp/.gitkeep",""
                create_file "db/.gitkeep", ""

            end

            def create_client_files
                self.class.source_root.join('client').children.each do | path |
                    next unless path.directory?
                    empty_directory "#{client_dir}/#{path.basename}"
                    create_file "#{client_dir}/#{path.basename}/.gitkeep"
                end
                template "client/models/BaseModel.coffee", "#{client_dir}/models/Base.coffee"
                template "client/components/BaseComponent.coffee",   "#{client_dir}/components/Base.coffee"
                template "client/index.js",                "#{client_dir}/index.js"
                template "client/Extension.coffee",        "#{client_dir}/Extension.coffee"
                template "client/styles.scss",             "#{client_dir}/styles.scss"
            end

            def create_spec_helpers
                template "spec/client/helpers/ClientHelpers.coffee",
                         "#{spec_dir}/helpers/#{namespace}Helpers.coffee"
                template "spec/server/spec_helpers.rb",
                         "spec/server/spec_helpers.rb"
            end

            def create_screen_base
                options = self.options.dup
                template "client/screens/BaseScreen.coffee", "#{client_dir}/screens/Base.coffee"
            end

        end

    end
end
