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

    def test_logos
        settings = Lanes::SystemSettings.new
        Tempfile.open do |tf1|
            tf1.write fixtures_path.join('logo.png').read
            tf1.rewind
            Tempfile.open do |tf2|
                tf2.write fixtures_path.join('logo.png').read
                tf2.rewind

                settings.build_logo(file: tf1)
                settings.build_print_logo(file: tf2)
                assert_saves settings
            end
        end
    end

end
