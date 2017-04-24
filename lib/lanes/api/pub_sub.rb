require_relative 'cable'

module Lanes
    module API

        class PubSub < Cable::Channel
            PREFIX = 'ps:'

            def on(data)
                stream_from channel_prefix + data['channel']
            end

            def off(data)
                channel = channel_prefix + data['channel']
                cb = pubsub.instance_variable_get('@listener')
                       .instance_variable_get('@subscribers')[channel].first
                pubsub.unsubscribe(channel, cb)
            end

            def self.publish(channel, data)
                channel = channel_prefix + channel
           #     ActionCable.server.broadcast(channel, data.merge(channel: channel))
            end

            def self.channel_prefix
                PREFIX
            end

            def channel_prefix
                PREFIX
            end

        end

    end
end
