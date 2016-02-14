require 'sinatra'
require 'oj'
require 'rack/protection'
require_relative 'sprockets_extension'
require_relative 'helper_methods'
require_relative 'pub_sub'


module Lanes
    module API
        class Root < Sinatra::Application

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
                use Rack::Protection #, :skip=>['GET:/'], :raise => true

                Lanes::Configuration.apply
            end

        end
    end
end
