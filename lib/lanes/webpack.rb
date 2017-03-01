require 'forwardable'
require 'erb'

module Lanes

    class Webpack

        TMP = Pathname.new(Dir.pwd).join('tmp')
        TEMPLATES = Pathname.new(__FILE__).dirname.join('..', '..', 'templates', 'js')

        extend Forwardable
        def_delegators :@process, :port, :environment, :stop, :alive?, :start, :wait

        attr_reader :generated_asset_dir

        def self.server
            config = WebpackDriver::Configuration.new(
                Pathname.new(__FILE__).dirname.join('..','js','webpack.config.js'),
                directory: Pathname.new(__FILE__).dirname.join('..', '..'),
                cmd_line_flags: ['--hot', '--inline'],
                logger: Lanes.logger
            )

            Webpack.new(config)
        end

        attr_reader :process

        def api_host
            Lanes.env.production? ? '' : "http://localhost:#{API::Root.settings.port}"
        end

        def initialize(config)

            @generated_asset_dir = Pathname.new(Dir.mktmpdir)
            generated_asset_dir.join('lanes').mkpath
            write_asset_files

            puts Extensions.map{|ext| ext.root_path.join('client').to_s }.join(',')

            config.environment.merge!(
                LANES_EXT_ROOTS: Extensions.map{|ext|
                    ext.root_path.join('client').to_s
                }.join(','),
                LANES_GENERATED_DIR: generated_asset_dir.to_s
            )

            @process = ::WebpackDriver::DevServer.new(config)
        end

        def write_asset_files
            screens = ERB.new(TEMPLATES.join('screens.js').read)
            root_view  = ERB.new(TEMPLATES.join('root-view.html').read)
            generated_asset_dir
                .join('lanes', 'screen-definitions.js')
                .write(screens.result(binding))
            generated_asset_dir
                .join('root-view.tmpl.html')
                .write(root_view.result(binding))
        end

        def assets
            process.assets.keys.select{|a| a=~/.js$/ }.reverse
        end

        def port
            process.port
        end
    end

end
