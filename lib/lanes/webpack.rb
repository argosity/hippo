require 'forwardable'
require 'fileutils'
require 'pathname'
require 'erb'

module Lanes

    class Webpack

        TMP = Pathname.new(Dir.pwd).join('tmp')
        TEMPLATES = Pathname.new(__FILE__).dirname.join('..', '..', 'templates', 'js')

        extend Forwardable
        def_delegators :@process, :port, :environment, :stop, :alive?, :start, :wait
        attr_reader :process

        def initialize
            controller = Command.load_current_extension(raise_on_fail: true)

            config = WebpackDriver::Configuration.new(
                controller.root_path.join('config', 'webpack.config.js'),
                cmd_line_flags: ['--hot', '--inline'],
                logger: Lanes.logger,
                directory: controller.root_path
            )

            generated_asset_dir = write_asset_files

            config.environment.merge!(
                EXTENSION_ID: controller.identifier,
                LANES_MODULES: modules(controller, generated_asset_dir).join(':'),
                ENTRY: 'show-maker/index.js',
                GENERATED_CONFIG_DIR: generated_asset_dir.to_s
            )
            @process = ::WebpackDriver::DevServer.new(config)
        end


        def api_host
            Lanes.env.production? ?
                '' : "http://localhost:#{API::Root.settings.port}"
        end

        def modules(controller, generated_asset_dir)
            Extensions.asset_paths(controller, generated_asset_dir.to_s)
        end

        def write_asset_files
            dir = Pathname.new(Dir.mktmpdir)
            dir.join('lanes').mkpath

            screens = ERB.new(TEMPLATES.join('screens.js').read)
            root_view = ERB.new(TEMPLATES.join('root-view.html').read)
            dir
                .join('lanes', 'screen-definitions.js')
                .write(screens.result(binding))
            template = dir.join('root-view.tmpl.html')
            template.write(root_view.result(binding))
            # set the mtime to the past, otherwise Webpack will build repeatedly for a second
            FileUtils.touch template.to_s, :mtime => Time.now - 1.minute
            return dir
        end

        def assets
            process.assets.keys.select{|a| a=~/.js$/ }.reverse
        end

        def port
            process.port
        end
    end

end
