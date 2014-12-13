require "lanes/spec_helper"

class ExportMethodsTest < Lanes::TestCase
    include TestingModels

    def around(&block)
        with_testing_models(&block)
    end

    def setup
        # @model = TestModel.new
        # @model.bt = TestModelBelongsTo.new
    end

    def teardown
#        TestModel.send( :remove_method, :bt_description ) if User.new.respond_to?( :bt_description )
    end


    def test_simple_delegation


        refute TestModel.new.respond_to? :bt_description

        TestModel.send :delegate_and_export, "bt_description"

        md = TestModel.new
        assert md.respond_to? :bt_description, "Didn't add transaction_description method"
        assert_nil md.bt_description
        md.build_bt( description: "test123" )
        assert_equal "test123", md.bt_description

        assert TestModel.has_exported_method?( :bt_description, nil ), "Didn't export method"
    end

    def test_dependancy_calculation
        TestModel.send :delegate_and_export, "bt_description"
        TestModel.send :delegate_and_export, "bt_notes", optional: false
        assert_includes TestModel.exported_method_dependancies([]), :bt
        assert_includes TestModel.exported_method_dependancies(['bt_description']), :bt
    end

end
