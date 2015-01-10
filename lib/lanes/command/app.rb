module Lanes
    module Command

        class App < NamedCommand

            class_options :force => :boolean

            class_option  :directory, :type=>:string


            def load_namespace # override
                @namespace  = name
            end

            def set_variables
                super
                self.destination_root = options[:directory] || name
            end

            def create_files
                ["Gemfile", "Rakefile", "Guardfile", "config.ru", "config/database.yml"].each do | file |
                    template file
                end
                template "lib/namespace.rb", "lib/#{name}.rb"
                template "lib/namespace/version.rb", "lib/#{name}/version.rb"
                template "lib/namespace/extension.rb", "lib/#{name}/extension.rb"
                template "lib/namespace/base_model.rb", "lib/#{name}/model.rb"
                template "config/routes.rb"
                template "config/lanes.rb"
                template "gitignore",".gitignore"
                create_file "tmp/.gitkeep",""
                create_file "db/.gitkeep", ""
                create_file "config/screens.rb"
            end

            def create_client_files
                self.class.source_root.join('client').children.each do | path |
                    next unless path.directory?
                    empty_directory "#{client_dir}/#{path.basename}"
                    create_file "#{client_dir}/#{path.basename}/.gitkeep"
                end
                template "client/models/BaseModel.coffee", "#{client_dir}/models/Base.coffee"
                template "client/models/BaseView.coffee",  "#{client_dir}/views/Base.coffee"
                template "client/index.js",         "#{client_dir}/index.js"
                template "client/Extension.coffee", "#{client_dir}/Extension.coffee"
                template "client/styles.scss",      "#{client_dir}/styles.scss"
            end

            def create_spec

            end

            def create_first_screen
                template "client/screens/Screen.coffee", "#{client_dir}/screens/Base.coffee"
            end
        end

    end
end
