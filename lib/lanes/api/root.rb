require 'sinatra'
require 'oj'
require 'rack/protection'
require_relative 'sprockets_extension'
require_relative 'helper_methods'
require_relative 'pub_sub'


module Lanes
    module API
        class Root < Sinatra::Application
            CORS_PATHS = {}

            Lanes.config.get(:environment) do | env |
                set :environment, env
            end
            register SprocketsExtension
            helpers RequestWrapper
            helpers HelperMethods
            helpers FormattedReply
            use Rack::Session::Cookie, :key => 'lanes.session', :secret => Lanes.config.session_secret_key_base
            use ActiveRecord::ConnectionAdapters::ConnectionManagement
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
                set :views, Pathname.new(__FILE__).dirname.join("../../../views")
                set :show_exceptions, false
                require_relative 'routing'

                PubSub.initialize(self)
                Extensions.load_controlling_config
                # late load in case an extension has provided an alternative implementation
                unless API.const_defined?(:AuthenticationProvider)
                    require "lanes/api/null_authentication_provider"
                end
                Lanes::Configuration.apply
            end

            configure do
                cors_resources = []

                if API::Root::CORS_PATHS.any?
                    use Rack::Cors, debug: !Lanes.env.production? do

                        API::Root::CORS_PATHS.each do | path, options |
                            allow do
                                cors_resources.push  Rack::Cors::Resource.new('', path)
                                origins options[:origins]
                                resource path, :methods => options[:methods], :headers => :any
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
