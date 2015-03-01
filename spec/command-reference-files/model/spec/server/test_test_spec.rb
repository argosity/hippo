require_relative 'spec_helpers'

class TestTestSpec < AppyApp::TestCase

    it "can be instantiated" do
        model = TestTest.new
        model.must_be_instance_of(TestTest)
    end

end
