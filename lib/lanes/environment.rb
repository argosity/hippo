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
    end

    # @return [Environment]
    def self.env
        @environment ||= Environment.new
    end
end
