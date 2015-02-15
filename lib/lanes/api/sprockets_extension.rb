require 'sprockets'
require 'sass'
require 'sinatra/sprockets-helpers'
require_relative 'javascript_processor'
require 'compass/import-once/activate'
require 'sprockets-helpers'

module Lanes
    module API
        module SprocketsExtension
            class << self

                def compile!
                    env = ::Sprockets::Environment.new
                    Lanes::API::SprocketsExtension.configure(env, compress:true)
                    manifest = Sprockets::Manifest.new( env.index, "public/assets/manifest.json" )
                    manifest.compile('lanes/workspace.js', 'lanes/workspace.css',
                                     'lanes/minimal.js',   'lanes/minimal.css' )
                    Extensions.each{|ext|
                        images = ext.client_images.map(&:to_s)
                        manifest.compile( images ) unless images.empty?
                    }
                    Screen.each do | screen |
                        assets = screen.assets
                        manifest.compile( assets ) unless assets.empty?
                    end
                end

                def configure(env, compress:false)
                    root = Pathname.new(__FILE__).dirname.join("../../..")
                    Lanes.config.get(:environment) do
                        unless Lanes.env.production?
                            env.cache = ::Sprockets::Cache::FileStore.new(Pathname.pwd.join('tmp','cache'))
                        end
                    end

                    Lanes::Extensions.each do | ext |
                        ext.on_boot
                        ext.client_paths.each{ |path| env.append_path(path) }
                    end

                    if compress
                        require_relative 'sprockets_compressor'
                        env.js_compressor  = AssetCompressor
                        env.css_compressor = AssetCompressor
                    end
                    env.append_path root.join('client')
                    JsAssetCompiler.register(env)
                end

                def registered(app)
                    app.register Sinatra::Sprockets::Helpers
                    app.set :sprockets, ::Sprockets::Environment.new
                    configure(app.sprockets)

                    app.configure do
                        ::Sprockets::Helpers.configure do |config|
                            config.environment = app.sprockets
                            config.prefix      = Lanes.config.assets_path_prefix
                            config.public_path = app.public_folder
                            config.debug = !app.production?
                            if app.production?
                                config.manifest = Sprockets::Manifest.new(app.sprockets,
                                                      "public/assets/manifest.json")
                            end
                        end
                    end

                    app.configure :test, :development do
                        app.get "#{Lanes.config.assets_path_prefix}/*" do |path|
                            env_sprockets = request.env.dup
                            env_sprockets['PATH_INFO'] = path
                            settings.sprockets.call env_sprockets
                        end
                    end
                    app.configure :production do
                        app.get "#{Lanes.config.assets_path_prefix}/*" do |path|
                            if manifest_path = ::Sprockets::Helpers.manifest.assets[path]
                                path = manifest_path
                            end
                            send_file "public/assets/" + path
                        end
                    end
                end

            end
        end
    end
end
