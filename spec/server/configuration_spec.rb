require_relative "spec_helper"

describe Lanes::Configuration do

    def test_changing_values_are_logged
        begin
            assert_logs_matching( /environment changed from / ) do
                Lanes.config.environment='foo'
            end
        ensure
            Lanes.silence_logs {   Lanes.config.environment='foo' }
        end
    end

    def test_callbacks_are_fired
        sentinel = false
        Lanes.config.on_change(:environment) do |nv,ov|
            sentinel = nv
        end
        Lanes.silence_logs do
            Lanes.config.environment = :testing
            assert_equal sentinel, :testing
        end
    end

end
