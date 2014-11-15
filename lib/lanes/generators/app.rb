module Lanes
    module Generators

        class App < Thor::Group
            include Thor::Actions

            class_options :force => :boolean

            class_option :test_framework, :type => :string
            class_option  :directory, :type=>:string

            argument :name

            def self.source_root
                Pathname.new(__FILE__).dirname.join("app")
            end

            def initialize(*args)
                super
                self.destination_root = options[:directory] || name
            end

            def create_files
                template "Gemfile"
                template "Rakefile"
                template "Guardfile"
                template "config.ru"
                template "config/database.yml"
                template "lib/main_class.rb", "lib/#{name}.rb"
                template "lib/main_class/version.rb", "lib/#{name}/version.rb"
                empty_directory "tmp"
            end

        end
    end
end
