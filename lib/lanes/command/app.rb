module Lanes
    module Command

        class App < Thor::Group
            include Thor::Actions

            class_options :force => :boolean

            class_option  :directory, :type=>:string

            argument :name
            attr_reader :file_name, :namespace, :class_name

            def self.source_root
                Pathname.new(__FILE__).dirname.join("templates")
            end

            def initialize(*args)
                super
                self.destination_root = options[:directory] || name
                @file_name = name.downcase
                @class_name = @namespace = name.camelize
            end

            def create_files
                ["Gemfile", "Rakefile", "Guardfile", "config.ru", "config/database.yml"].each do | file |
                    template file
                end
                template "lib/namespace.rb", "lib/#{name}.rb"
                template "lib/namespace/version.rb", "lib/#{name}/version.rb"
                template "lib/namespace/extension.rb", "lib/#{name}/extension.rb"
                template "config/routes.rb"
                template "config/lanes.rb"
                template "gitignore",".gitignore"
                create_file "tmp/.gitkeep",""
                create_file "db/.gitkeep", ""
            end

            def create_client_files
                self.class.source_root.join('client').children.each do | path |
                    empty_directory "client/#{path.basename}" if path.directory?
                end
                template "client/namespace-extension.js", "client/#{name}-extension.js"
                template "client/Extension.coffee",   "client/Extension.coffee"
                template "client/styles/styles.scss", "client/#{name}-styles.scss"
            end

            def create_first_screen
                invoke GenerateScreen, [name], title: name.titleize, namespace: name
            end
        end

    end
end
