# coding: utf-8
require 'knitter'

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
                [ "Gemfile", "Rakefile", "Guardfile", "config.ru",
                  "config/database.yml"
                ].each{ |f| template(f) }
                [ ".eslintrc.js", ".babelrc", ".rubocop.yml"
                ].each{ |f| template("../#{f}", f) }
                template "lib/namespace.rb", "lib/#{identifier}.rb"
                template "lib/namespace/version.rb", "lib/#{identifier}/version.rb"
                template "lib/namespace/extension.rb", "lib/#{identifier}/extension.rb"
                template "lib/namespace/base_model.rb", "lib/#{identifier}/model.rb"
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
                template "client/models/base.js",   "#{client_dir}/models/base.js"
                template "client/index.js",         "#{client_dir}/index.js"
                template "client/extension.js",     "#{client_dir}/extension.js"
                template "client/styles.scss",      "#{client_dir}/styles.scss"
            end

            def create_spec_helpers
                template "spec/client/setup.js",
                         "spec/client/setup.js"
                template "spec/server/spec_helper.rb",
                         "spec/server/spec_helper.rb"
            end

            def knitterize
                say 'Installing node modules', :green
                yarn = Knitter::Yarn.new(self.destination_root)
                yarn.init
                [
                    'lanes-framework',
                    'jest',
                    'babel-jest',
                    'webpack-dev-server'
                ].each do | package_name |
                    say(sprintf('    %-20s…', package_name), nil, false)
                    package = Knitter::Package.new(package_name, yarn: yarn)
                    package.add
                    say 'done', :green
                end

            end
        end
    end
end
