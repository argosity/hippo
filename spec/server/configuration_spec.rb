require_relative "spec_helper"

describe Hippo::Configuration do

    def test_changing_values_are_logged
        begin
            assert_logs_matching( /environment changed from / ) do
                Hippo.config.environment='foo'
            end
        ensure
            Hippo.silence_logs {   Hippo.config.environment='foo' }
        end
    end

    def test_callbacks_are_fired
        sentinel = false
        Hippo.config.on_change(:environment) do |nv,ov|
            sentinel = nv
        end
        Hippo.silence_logs do
            Hippo.config.environment = :testing
            assert_equal sentinel, :testing
        end
    end

end
