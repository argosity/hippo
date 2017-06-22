require_relative "../spec_helper"

describe "ApiPath" do

    include TestingModels

    around do |example|
        with_testing_models do
            example.run
        end
    end

    it "generates path" do
        expect('test-model').to eq(TestModel.api_path)
    end

    it "converts path to model" do
        expect(TestModel).to eq(Hippo::Model.from_api_path('test-model'))
    end
end
