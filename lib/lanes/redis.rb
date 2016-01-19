require 'redis'

module Lanes

    # returns a persistent connection to the Redis instance
    def self.redis_connection(cache: true)
        if cache
            @@REDIS ||= ::Redis.new(Lanes.config.redis)
        else
            ::Redis.new(Lanes.config.redis)
        end
    end
end
