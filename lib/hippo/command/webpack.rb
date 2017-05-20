require 'forwardable'
require 'fileutils'
require 'pathname'

module Hippo

    module Command

        class Webpack < Thor::Group
            include Thor::Actions

            attr_reader :webpack

            attr_accessor :config

            attr_reader :wpd_config

            class_option :compile, :type => :boolean, default: false

            def set_production_env
                ext = Command.load_current_extension
                Hippo.config.environment = :production if options[:compile]
            end

            def launch
                @webpack = Hippo::Webpack.new
            end

            def startup
                process = webpack.process
                process.start if options[:compile]
                process.wait
            end

        end
    end
end
