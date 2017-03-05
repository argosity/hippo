require_relative 'spec_helper'

describe <%= identifier %>::<%= class_name %> do

    it "can be instantiated" do
        model = <%= identifier %>::<%= class_name %>.new
        expect( model ).to be_an(<%= identifier %>::<%= class_name %>)
    end

end
