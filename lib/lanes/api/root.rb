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
            helpers Sinatra::RequestWrapper
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
                get "#{prefix}/#{path}/?:id?.json" do
                    wrap_request(model, params, parent_attribute) do |authentication|
                        controller.new(model, authentication, params).perform_retrieval
                    end
                end

                # create
                post "#{prefix}/#{path}.json" do
                    wrap_request(model, params, parent_attribute) do |authentication|
                        controller.new(model, authentication, params, data).perform_creation
                    end
                end

                unless options[:immutable]
                    patch "#{prefix}/#{path}/:id.json" do
                        perform_request(model, params, parent_attribute) do |authentication|
                            controller.new(model, authentication, params, data).perform_update
                        end
                    end

                    # update
                    put "#{prefix}/#{path}/:id.json" do
                        wrap_request(model, params, parent_attribute) do |authentication|
                            controller.new(model, authentication, params, data).perform_update
                        end
                    end

                    unless options[:indestructible]
                        # destroy
                        delete "#{prefix}/#{path}/:id.json" do
                            wrap_request(model, params, parent_attribute) do |authentication|
                                controller.new(model, authentication, params).perform_destroy
                            end
                        end
                    end

                end

            end

        end
    end
end
