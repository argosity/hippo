require_relative "spec_helper"
require "lanes/cli"
require "find"

class Lanes::AssetTest < Lanes::TestCase

    include TestingModels

    def setup
        TestModel.has_one :asset, as: :owner, :class_name=>'Lanes::Asset'
        @model = TestModel.new
    end

    def test_saveing_image
        @model.build_asset(file: fixtures_path.join('logo.png').open)
        assert @model.save
        assert_equal @model.asset.as_json['metadata'], {
            'content_type' => 'image/png',
            'width'        => 500,
            'height'       => 223,
            'size'         => 49172
        }
    end

    def test_saving_blob
        @model.build_asset(file: fixtures_path.join('system_settings.yml').open)
        assert @model.save
        assert_equal @model.asset.as_json['metadata'], {
            'content_type' => 'text/x-yaml',
            'size'         => 1
        }
    end

end
