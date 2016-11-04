require_relative 'cable'

module Lanes
    module API

        class PubSub < Cable::Channel
            PREFIX = 'ps:'
            def on(data)
                channel = PREFIX + data['channel']
                stream_from channel
            end

            def off(data)
                channel = PREFIX + data['channel']
                cb = pubsub.instance_variable_get('@listener')
                       .instance_variable_get('@subscribers')[channel].first
                pubsub.unsubscribe(channel, cb)
            end

            def self.publish(channel, data)
                ActionCable.server.broadcast(
                    PREFIX + channel,
                    data.merge(channel: channel)
                )
            end

        end

    end
end
