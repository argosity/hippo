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

            def make_config
                return if @config
                @config = ClientConfig.new
                config.invoke_all
            end

            def configure
                @wpd_config = WebpackDriver::Configuration.new(
                    config.extension_path.join('config', 'webpack.config.js'),
                    cmd_line_flags: ['--hot', '--inline'],
                    logger: Lanes.logger,
                    directory: config.controlling_extension.root_path
                )

                wpd_config.environment.merge!(
                    EXTENSION_ID: config.controlling_extension.identifier,
                    LANES_MODULES: config.module_paths.join(':'),
                    ENTRY: "#{config.controlling_extension.identifier}/index.js",
                    GENERATED_CONFIG_DIR: config.directory.to_s
                )

                self
            end

            def startup
                @process = ::WebpackDriver::DevServer.new(wpd_config)
                @process.start
                @process.wait if options[:wait]
            end

        end
    end

end
