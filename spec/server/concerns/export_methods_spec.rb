require_relative "../spec_helper"

describe "Exporting Methods" do
    include TestingModels

    around(:each) do |example|
        with_testing_models do
            example.run
        end
    end

    it 'can use simple delegation' do

        expect(TestModel.new).to_not respond_to(:bt_description)

        TestModel.send :delegate_and_export, "bt_description"

        md = TestModel.new
        expect(md).to respond_to(:bt_description)
        expect(md.bt_description).to be_nil
        md.build_bt( description: "test123")
        expect(md.bt_description).to eq("test123")

        expect(TestModel.has_exported_method?( :bt_description, nil )).to be(true)
    end

    def test_dependancy_calculation
        TestModel.send :delegate_and_export, "bt_description"
        TestModel.send :delegate_and_export, "bt_notes", optional: false
        expect(TestModel.exported_method_dependancies([])).to include(:bt)
        expect(TestModel.exported_method_dependancies(['bt_description'])).to include(:bt)
    end

end
