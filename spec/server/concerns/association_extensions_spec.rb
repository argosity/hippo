require_relative "../spec_helper"

describe "AssociationExtensions" do

    include TestingModels

    around(:each) do |example|
        with_testing_models do
            example.run
        end
    end

    it "adds event listener that requires inverse" do
        expect {
            TestModel.has_one(:tmhm, :listen=>{:save=>:on_save})
        }.to raise_error(ArgumentError, /the association does not have an inverse_of/)
    end

    it "does not allow other garbage" do
        expect {
            TestModel.has_one(:tmhm,:blarg=>true)
        }.to raise_error(ArgumentError, /Unknown key/)
    end
end
