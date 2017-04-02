require 'forwardable'
require 'fileutils'
require 'pathname'

module Lanes

    module Command

        class Webpack < Thor::Group
            include Thor::Actions

            attr_reader :process

            attr_accessor :config

            attr_reader :wpd_config

            class_option :wait, :type => :boolean, default: true,
                         desc: "Whether to keep running and wait for exit"

            class_option :compile, :type => :boolean, default: false

            def set_production_env
                Lanes.config.environment = :production if options[:compile]
            end

            def make_config
                return if @config
                @config = ClientConfig.new
                config.invoke_all
            end

            def configure
                @wpd_config = WebpackDriver::Configuration.new(
                    config.directory.join('webpack.config.js'),
                    logger: Lanes.logger,
                    directory: config.controlling_extension.root_path,
                    cmd_line_flags: (options[:compile] ? [] : ['--hot', '--inline']),
                    environment: { NODE_ENV: options[:compile] ? 'production' : 'development' }
                )
                self
            end

            def create_process
                @process = options[:compile] ? ::WebpackDriver::Compile.new(wpd_config) :
                               ::WebpackDriver::DevServer.new(wpd_config)
            end

            def startup
                process.start
                process.wait if options[:wait]
            end

        end
    end

end
