require_relative "spec_helper"

describe Hippo::Asset do

    include TestingModels

    around(:each) do |example|
        with_testing_models do
            TestModel.has_one :asset, as: :owner, :class_name=>'Hippo::Asset'
            example.run
        end
    end

    it 'saves image' do
        tm = TestModel.new
        @model = TestModel.new
        asset = @model.build_asset
        tf=Tempfile.new
        tf.write fixtures_path.join('logo.png').read
        tf.rewind
        asset.file = {
            type: "image/png", name: "file",
            filename: "Screen Shot 2016-10-28 at 5.15.37 PM.png",
            head: "Content-Disposition: form-data; name=\"file\"; filename=\"Screen Shot 2016-10-28 at 5.15.37 PM.png\"\r\nContent-Type: image/png\r\n",
            tempfile: tf
        }

        expect(@model.save).to eq(true)

        expect(@model.asset.file_data.keys).to eq(["original", "medium", "thumbnail"])
        expect(
            @model.asset.file_data['original']['metadata'].without('filename')
        ).to include(
                 "mime_type" =>"image/png",
                 "size"      => a_value_within(100).of(42200), # different magic versions will be different size
                 "width"     =>500,
                 "height"    =>223
                )

    end

end
