require "oj"

require_relative "updates"

require 'message_bus'

module Lanes
    module API

        class PubSub

            def self.publish(channel, data)
                MessageBus.publish channel, data #Oj.dump(data, mode: :compat)
            end

            def self.initialize
                # Use OJ - it encodes dates properly as ISO 8601
                # https://github.com/moment/moment/issues/1407
                Oj.mimic_JSON()
                # # Requiring json here seems to stop conflicts when requiring json in other files.
                begin
                    require 'json'
                rescue Exception
                    # ignore
                end
                ::MessageBus.redis_config = Lanes.config.redis
                Updates.relay!
            end

        end

    end
end
