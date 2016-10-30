require_relative "spec_helper"
# require "lanes/cli"
# require "find"

class Lanes::AssetTest < Lanes::TestCase

    include TestingModels

    def setup
        TestModel.has_one :asset, as: :owner, :class_name=>'Lanes::Asset'
    end

    def test_saveing_image
        tm = TestModel.new
        @model = TestModel.new
        asset = @model.build_asset# (file: fixtures_path.join('logo.png').open)
        tf=Tempfile.new
        tf.write fixtures_path.join('logo.png').read
        tf.rewind
        asset.file = {
            type: "image/png", name: "file",
            filename: "Screen Shot 2016-10-28 at 5.15.37 PM.png",
            head: "Content-Disposition: form-data; name=\"file\"; filename=\"Screen Shot 2016-10-28 at 5.15.37 PM.png\"\r\nContent-Type: image/png\r\n",
            tempfile: tf
        }
        assert @model.save

        assert_equal(@model.asset.file_data.keys, ["original", "medium", "thumbnail"])
        assert_equal(
            @model.asset.file_data['original']['metadata'].without('filename'), {
                "size"=>42228,
                "mime_type"=>"image/png",
                "width"=>500,
                "height"=>223
            }
        )
    end

end
