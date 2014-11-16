module Lanes
    module Generators

        class App < Thor::Group
            include Thor::Actions

            class_options :force => :boolean

            class_option  :directory, :type=>:string

            argument :name
            attr_reader :file_name, :class_name

            def self.source_root
                Pathname.new(__FILE__).dirname.join("app")
            end

            def initialize(*args)
                super
                self.destination_root = options[:directory] || name
                @class_name = name.camelize
            end

            def create_files
                ["Gemfile", "Rakefile", "config.ru", "config/database.yml"].each do | file |
                    template file
                end
                template "lib/namespace.rb", "lib/#{name}.rb"
                template "lib/namespace/version.rb", "lib/#{name}/version.rb"
                empty_directory "tmp"
                template "client/javascripts/index.js",  "client/javascripts/#{name}/index.js"
                template "client/stylesheets/index.css", "client/stylesheets/#{name}/index.css"
            end

        end
    end
end
