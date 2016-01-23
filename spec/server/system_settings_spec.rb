require_relative "spec_helper"
require "lanes/cli"
require "find"

describe Lanes::SystemSettings do

    setup do
        # needed because otherwise the rollback will leave configs without a db record
        Lanes::SystemSettings.instance_variable_set(:@config, nil)
    end

    def test_getting_config
        assert_kind_of Lanes::SystemSettings::ExtensionSettings, Lanes::SystemSettings.for_ext('foo')
    end

    def test_persisting_config
        settings = Lanes::SystemSettings.for_ext('foo')
        settings.foo = 'bar'
        settings.persist!
        assert_equal({foo: 'bar'}, Lanes::SystemSettings.for_ext('foo').to_h)
    end

    def test_clear_on_modify
        current = Lanes::SystemSettings._config
        assert_same current, Lanes::SystemSettings._config
        settings = Lanes::SystemSettings.for_ext('foo')
        settings.persist!
        assert_not_same current, Lanes::SystemSettings._config
    end

end