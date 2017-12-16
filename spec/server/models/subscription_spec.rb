require_relative '../spec_helper'

describe Hippo::Subscription do

    it "can be instantiated" do
        model = Hippo::Subscription.new
        expect(model).to be_an(Hippo::Subscription)
    end

end
