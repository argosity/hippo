require 'redis'

module Hippo

    # returns a persistent connection to the Redis instance
    def self.redis_connection(cache: true)
        if cache
            @@REDIS ||= ::Redis.new(Hippo.config.redis)
        else
            ::Redis.new(Hippo.config.redis)
        end
    end
end
