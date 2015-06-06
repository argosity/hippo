require 'sinatra'
require 'oj'
require 'rack/csrf'

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
            use Rack::Session::Cookie, :key => 'lanes.session', :secret => Lanes.config.session_secret_key_base
            use ActiveRecord::ConnectionAdapters::ConnectionManagement
            not_found do
                Oj.dump({ message: "endpoint not found", success: false  })
            end
            error do
                Lanes.logger.warn request.env['sinatra.error']
                Oj.dump({
                    success: false,
                    errors:  { exception: request.env['sinatra.error'].message },
                    message: request.env['sinatra.error'].message
                })
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

            configure do
                set :views, Pathname.new(__FILE__).dirname.join("../../../views")
                set :show_exceptions, false
                require_relative 'routing'

                DB.establish_connection
                PubSub.initialize(self)
                Extensions.load_controlling_config
                # late load in case an extension has provided an alternative implementation
                unless API.const_defined?(:AuthenticationProvider)
                    require "lanes/api/null_authentication_provider"
                end
                # use Rack::Csrf, :skip=>['GET:/'], :raise => true
            end

        end
    end
end
