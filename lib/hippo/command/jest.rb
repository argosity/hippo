require_relative '../extension'
require_relative '../command'
require_relative '../webpack/client_config'

module Hippo
    module Command

        class Jest < Thor::Group
            include Thor::Actions

            attr_reader :config

            class_option :watch, :type => :boolean, default: false,
                         desc: "Whether to keep running and watch for file changes"

            class_option :debug, :type => :boolean, default: false


            def configure
                @config = Hippo::Webpack::ClientConfig.new
                @config.invoke_all
                self
            end

            def config_file
                config.directory.join('jest.config.json')
            end

            def start
                say 'Starting Jest', :green
                say Dir.pwd, :yellow
                cmd = "$(npm bin)/jest --config #{config_file}"
                options.each do |key, value|
                    cmd << " --#{key}" if value
                end
                exec(cmd)
            end
        end
    end
end
