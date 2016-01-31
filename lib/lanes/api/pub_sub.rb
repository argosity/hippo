require 'message_bus'

module Lanes
    module API

        class PubSub

            def self.publish(channel, data)
                ::MessageBus.publish channel, data
            end

            def self.initialize(api=nil)
                #return unless Extensions.require_pub_sub?
                Lanes.config.get(:environment) do | env |
                    MessageBus.logger = Lanes.logger
                end

                require "oj"
                require_relative "updates"
                require 'message_bus'
                api.use MessageBus::Rack::Middleware if api


                if defined?(PhusionPassenger)
                    PhusionPassenger.on_event(:starting_worker_process) do |forked|
                        MessageBus.after_fork if forked
                    end
                end

                Updates.relay!

                ::Lanes::API.routes.draw do
                    post '/file-change.json' do
                        ::Lanes::API::PubSub.publish("/file-change", data)
                        "OK"
                    end
                end

            end

        end

    end
end
