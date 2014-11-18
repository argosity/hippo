require_relative 'spec_helper'

describe <%= namespace.camelize %>::<%= class_name %> do

    it "can be instantiated" do
        model = <%= class_name %>.new
        model.must_be_instance_of(<%= class_name %>)
    end

end
