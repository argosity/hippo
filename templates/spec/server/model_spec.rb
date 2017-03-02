require_relative 'spec_helper'

class <%= class_name %>Spec < <%= namespace %>::TestCase

    it "can be instantiated" do
        model = <%= class_name %>.new
        model.must_be_instance_of(<%= class_name %>)
    end

end
