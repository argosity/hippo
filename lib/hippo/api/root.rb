require 'sinatra'
require 'oj'
require 'rack/protection'
require 'rack/cors'

module Hippo
    module API
        class Root < Sinatra::Application
            CORS_PATHS = {}

            Hippo.config.get(:environment) do | env |
                set :environment, env
            end
            helpers RequestWrapper
            helpers HelperMethods
            helpers FormattedReply

            use Rack::Session::Cookie,
                :key => 'rack.session',
                :secret => Hippo.config.session_secret_key_base
            not_found do
                Oj.dump({ message: "endpoint not found", success: false  })
            end
            error ActiveRecord::RecordNotFound do
                halt 404, error_as_json
            end
            error do
                error_as_json
            end

            configure do
                set :show_exceptions, false

                Hippo::Configuration.apply
                Hippo::Extensions.load_controlling_config
                set :views, Hippo::Extensions.controlling.root_path.join('views')
                set :webpack, Hippo::Webpack.new
                require_relative './routing'
                API::Cable.configure
            end

            configure do
                cors_resources = []
                if API::Root::CORS_PATHS.any?
                    use Rack::Cors, debug: !Hippo.env.production?, logger: Hippo.logger do
                        API::Root::CORS_PATHS.each do | path, options |
                            allow do
                                cors_resources.push  Rack::Cors::Resource.new('', path)
                                origins options[:origins]
                                resource path,
                                         :methods => options[:methods].map(&:to_sym) + [:options],
                                         :headers => :any
                            end
                        end

                    end

                end
                use Rack::Protection, allow_if: -> (env) {
                    path = env['PATH_INFO']
                    cors_resources.any?{|r| r.matches_path?(path) }
                }
            end
        end
    end
end
