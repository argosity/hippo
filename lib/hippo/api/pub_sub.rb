require_relative 'cable'

module Hippo
    module API

        class PubSub < Cable::Channel
            identifier :pubsub

            PREFIX = 'ps:'

            def on(data)
                Hippo.logger.info "pubsub  on: #{data['channel']}"
                stream_from channel_prefix + data['channel']
            end

            def off(data)
                Hippo.logger.info "pubsub off: #{data['channel']}"
                stop_stream channel_prefix + data['channel']
            end

            def self.publish(channel, data)
                Hippo.logger.info "pubsub pub: #{channel}"
                channel = channel_prefix + channel
                LiteCable.broadcast(channel, data.merge(channel: channel))
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
