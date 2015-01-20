require_relative 'spec_helpers'

class <%= class_name %>Spec < <%= namespace.camelize %>::TestCase

    it "can be instantiated" do
        model = <%= class_name %>.new
        model.must_be_instance_of(<%= class_name %>)
    end

end
