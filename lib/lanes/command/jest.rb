require 'guard/cli'
require 'webpack_driver'
require 'puma/cli'
require 'guard/jest'
require_relative './client_config'
require_relative '../extension'
require_relative '../command'
require 'irb'
module Lanes
    module Command

        class Jest < Thor::Group
            include Thor::Actions

            attr_reader :config

            class_option :watch, :type => :boolean, default: false,
                         desc: "Whether to keep running and watch for file changes"

            def configure
                @config = ClientConfig.new
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
                cmd << "  --watch" if options[:watch]
                exec(cmd)
            end
        end
    end
end
