require_relative 'cable'

module Hippo
    module API

        class PubSub < ActionCable::Channel::Base

            PREFIX = 'ps:'

            def on(data)
                Hippo.logger.info "pubsub  on: #{data['channel']}"
                stream_from channel_prefix + data['channel']
            end

            def off(data)
                channel = channel_prefix + data['channel']
                subscribers = pubsub
                                  .instance_variable_get('@listener')
                                  .instance_variable_get('@subscribers')[channel]
                pubsub.unsubscribe(channel, subscribers.first) if subscribers.any?
            end

            def self.publish(channel, data)
                channel = channel_prefix + channel
                ActionCable.server.broadcast(channel, data.merge(channel: channel))
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
