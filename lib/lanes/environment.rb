module Lanes

    class Environment
        def test?
            Lanes.config.environment == :test
        end
        def development?
            Lanes.config.environment == :development
        end
        def production?
            Lanes.config.environment == :production
        end
        def to_s
            Lanes.config.environment.to_s
        end
    end

    # @return [Environment]
    def self.env
        @environment ||= Environment.new
    end
end
