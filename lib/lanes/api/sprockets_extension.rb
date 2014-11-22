require 'sprockets'
require 'sass'
require 'sinatra/sprockets-helpers'
require_relative 'javascript_processor'

module Lanes
    module API
        module SprocketsExtension

            def self.configure(env)
                root = Pathname.new(__FILE__).dirname.join("../../..")
                Lanes.config.get(:environment) do
                    unless Lanes.env.production?
                        env.cache = ::Sprockets::Cache::FileStore.new(Pathname.pwd.join('tmp','cache'))
                    end
                end
                env.append_path root.join('client')
                JsAssetCompiler.register(env)
                Lanes::Extensions.each do | ext |
                    ext.client_paths.each{ |path| env.append_path(path) }
                end
            end

            def self.registered(app)
                app.register Sinatra::Sprockets::Helpers
                app.set :sprockets, ::Sprockets::Environment.new
                configure(app.sprockets)

                # The url for client
                app.set :digest_assets, false

                app.configure do
                    ::Sprockets::Helpers.configure do |config|
                        config.environment = app.sprockets
                        config.prefix      = Lanes.config.assets_path_prefix
                        config.digest      = app.digest_assets
                        config.public_path = app.public_folder
                        config.debug = true
                    end
                end

                app.configure :test, :development do
                    app.get "#{Lanes.config.assets_path_prefix}/*" do |path|
                        env_sprockets = request.env.dup
                        env_sprockets['PATH_INFO'] = path
                        settings.sprockets.call env_sprockets
                    end
                end
            end

        end
    end
end
