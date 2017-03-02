require 'guard/cli'
require 'webpack_driver'
require 'puma/cli'
require 'guard/jest'

require_relative '../extension'
require_relative '../command'
require 'irb'
module Lanes
    module Command

        class Jest < Thor::Group
            include Thor::Actions
            ROOT = Pathname.new(__FILE__).dirname.join("..", "..", "..")
            def self.source_root
                ROOT.join("templates")
            end

            class_option :config_dir
            attr_accessor :lanes_root_path
            attr_accessor :extension_path
            attr_accessor :config_file
            attr_accessor :module_paths

            def apply_lanes_config
                Lanes::Configuration.apply
                Lanes::Extensions.load_controlling_config
            end

            def configure
                say 'Generating Jest Config', :green
                ext = Command.load_current_extension(raise_on_fail: true)
                self.extension_path = ext.root_path
                self.lanes_root_path = ROOT
                config_dir = Pathname.new(Dir.mktmpdir)
                self.config_file = config_dir.join("jest.config.json")
                self.module_paths = Extensions.asset_paths(ext, config_dir.to_s)
                template('js/jest.config.json', config_file, verbose: false, force: true)
                self
            end

            def start
                say 'Starting Jest', :green
                say Dir.pwd, :yellow
                puts "$(npm bin)/jest --watch --config #{config_file};"
                exec("$(npm bin)/jest --watch --config #{config_file};")
            end
        end
    end
end
