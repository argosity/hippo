require_relative '../spec_helper'

describe <%= namespace %>::<%= class_name %> do

    it "can be instantiated" do
        model = <%= namespace %>::<%= class_name %>.new
        expect(model).to be_an(<%= namespace %>::<%= class_name %>)
    end

end
