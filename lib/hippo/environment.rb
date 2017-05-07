module Hippo

    class Environment
        def test?
            Hippo.config.environment == :test
        end
        def development?
            Hippo.config.environment == :development
        end
        def production?
            Hippo.config.environment == :production
        end
        def to_s
            Hippo.config.environment.to_s
        end
    end

    # @return [Environment]
    def self.env
        @environment ||= Environment.new
    end
end
