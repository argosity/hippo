require 'forwardable'
require 'erb'

module Lanes


    class Webpack

        TMP = Pathname.new(Dir.pwd).join('tmp')
        TEMPLATES = Pathname.new(__FILE__).dirname.join('..', '..', 'templates', 'js')

        extend Forwardable
        def_delegators :@process, :port, :environment, :stop, :alive?, :start, :wait

        attr_reader   :generated_asset_dir

        def self.server
            Webpack.new(
                WebpackDriver::DevServer.new(
                    '--port', '8889', '--hot', '--config',
                    Pathname.new(__FILE__).dirname
                        .join('..','js','webpack.config.js').expand_path.to_s
                )
            )
        end

        attr_reader :process

        def api_host
            Lanes.env.production? ? '' : "http://localhost:#{API::Root.settings.port}"
        end

        def initialize(process)
            @process = process
            @generated_asset_dir = Pathname.new(Dir.mktmpdir)
            generated_asset_dir.join('lanes').mkpath
            write_asset_files
            puts "RB Roots: "
            puts Extensions.map{|ext| ext.root_path.join('client').to_s }.join(',')

            @process.environment.merge!(
                LANES_EXT_ROOTS: Extensions.map{|ext| ext.root_path.join('client').to_s }.join(','),
                LANES_GENERATED_DIR: generated_asset_dir.to_s
            )

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
