require 'sinatra'
require 'oj'
require 'rack/csrf'
require 'sprockets-helpers'
require 'message_bus'
require_relative 'sprockets_extension'
require_relative 'helper_methods'
require_relative 'pub_sub'

module Lanes
    module API
        class Root < Sinatra::Application
            set :environment, Lanes.config.environment
            Lanes.config.get(:environment) do | env |
                set :environment, env
            end
            register SprocketsExtension
            helpers RequestWrapper
            helpers HelperMethods
            not_found do
                Oj.dump({ message: "endpoint not found", success: false  })
            end
            before do
                content_type 'application/json'
            end

            use Rack::Session::Cookie, :key => 'lanes.session', :secret => Lanes.config.session_secret_key_base
            use ActiveRecord::ConnectionAdapters::ConnectionManagement
            use MessageBus::Rack::Middleware
            error do
                Lanes.logger.warn request.env['sinatra.error']#.backtrace
                Oj.dump({
                    success: false,
                    errors:  { exception: request.env['sinatra.error'].message },
                    message: request.env['sinatra.error'].message
                })
            end

            configure do
                set :views, Pathname.new(__FILE__).dirname.join("../../../views")
                set :show_exceptions, false
                DB.establish_connection
                PubSub.initialize
                Extensions.load_current_config
                # late load in case an extension has provided an alternative implementation
                require "lanes/api/null_authentication_provider" unless API.const_defined?(:AuthenticationProvider)
                # use Rack::Csrf, :skip=>['GET:/'], :raise => true
            end

            def self.resources(model, options = {})

                path = options[:path] || model.api_path
                controller = options[:controller] || Lanes::API::Controller

                parent_attribute = false
                prefix = if options[:under]
                             parent_attribute = options[:parent_attribute] || options[:under].underscore.singularize+'_id'
                         else
                             ''
                         end

                # index
                get "#{prefix}/#{path}/?:id?.json", &RequestWrapper.get(model, controller, parent_attribute)

                # create
                post "#{prefix}/#{path}.json", &RequestWrapper.post(model, controller, parent_attribute)

                unless options[:immutable]

                    # update
                    patch "#{prefix}/#{path}/?:id?.json", &RequestWrapper.update(model, controller, parent_attribute)
                    put   "#{prefix}/#{path}/?:id?.json", &RequestWrapper.update(model, controller, parent_attribute)

                    unless options[:indestructible]
                        # destroy
                        delete "#{prefix}/#{path}/?:id?.json", &RequestWrapper.delete(model, controller, parent_attribute)
                    end

                end

            end

        end
    end
end
