require_relative '../spec_helper'

describe AppyApp::TestTest do

    it "can be instantiated" do
        model = AppyApp::TestTest.new
        expect(model).to be_an(AppyApp::TestTest)
    end

end
