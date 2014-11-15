require 'sprockets'
require 'sass'
require 'sass-css-importer'
require 'sinatra/sprockets-helpers'
require_relative 'javascript_processor'

module Lanes
    module API
        module AssetPipeline

            def self.configure(env)
                root = Pathname.new(__FILE__).dirname.join("../../..")
                Lanes.config.get(:environment) do
                    if Lanes.env.development?
                        env.cache = Sprockets::Cache::FileStore.new(root.join('tmp','cache'))
                    end
                end
                env.append_path root.join('client', 'javascripts')
                env.append_path root.join('client', 'stylesheets')
                env.append_path root.join('client', 'screens')
                env.append_path root.join('client', 'images')

                JsAssetCompiler.register(env)
            end

            def self.registered(app)
                app.register Sinatra::Sprockets::Helpers

                app.set :sprockets, Sprockets::Environment.new
                configure(app.sprockets)

                # The url for client
                app.set :assets_prefix, '/assets'

                app.set :digest_assets, false

                app.configure do

                    Sprockets::Helpers.configure do |config|
                        config.environment = app.sprockets
                        config.prefix      = app.assets_prefix
                        config.digest      = app.digest_assets
                        config.public_path = app.public_folder
                        config.debug = true
                    end
                end

                app.configure :test, :development do
                    app.get "#{app.assets_prefix}/*" do |path|
                        env_sprockets = request.env.dup
                        env_sprockets['PATH_INFO'] = path
                        settings.sprockets.call env_sprockets
                    end
                end
            end

        end
    end
end
