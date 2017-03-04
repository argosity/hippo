require_relative 'spec_helper'

describe <%= class_name %> do

    it "can be instantiated" do
        model = <%= class_name %>.new
        expect( model ).to be_an(<%= class_name %>)
    end

end
