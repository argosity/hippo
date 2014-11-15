require_relative '../spec_helper'

class ApiPathTest < Lanes::TestCase

    include TestingModels

    def test_path_generation
        assert_equal 'test-models', TestModel.api_path
    end

    def testing_path_to_model
        assert_equal TestModel, Lanes::Model.from_api_path('test-models')
    end
end
