require "resque"
require "resque/failure/multiple"
require "resque/failure/redis"
require "resque/failure/multiple"

module Hippo
    class Job
        class FailureLogger < ::Resque::Failure::Base

            def self.configure
                Resque::Failure::Multiple.configure do |multi|
                    # Always stores failure in Redis and writes to log
                    multi.classes = Resque::Failure::Redis, self
                end
            end

            def save
                Hippo.logger.error detailed
            end

            def detailed
                <<-EOF
#{worker} failed processing #{queue}:
Payload:
#{payload.inspect.split("\n").map { |l| "  " + l }.join("\n")}
Exception:
#{exception}
#{exception.backtrace.map { |l| "  " + l }.join("\n")}
EOF
            end
        end
    end
end
