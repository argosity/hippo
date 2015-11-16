require_relative 'spec_helper'

class TestTestSpec < AppyApp::TestCase

    it "can be instantiated" do
        model = TestTest.new
        model.must_be_instance_of(TestTest)
    end

end
