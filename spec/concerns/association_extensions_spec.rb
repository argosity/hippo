require_relative '../spec_helper'


class AssociationExtensionsTest < Lanes::TestCase

    include TestingModels

    def test_adding_event_listener_requires_inverse
        err = assert_raise(ArgumentError) do
            TestModel.has_one(:tmhm,:listen=>{:save=>:on_save})
        end
        assert_match( /does not have an inverse_of specified./, err.message )
    end

    def test_adds_listener
        Tmhm.expects(:_add_event_listener).with(:save,is_a(Proc))
        TestModel.has_one(:tmhm,:listen=>{:save=>:on_save}, :inverse_of=>:tm)
    end

    def test_exports_associations
        TestModel.expects(:export_associations).with(:tmhm,{})
        TestModel.has_one(:tmhm, export: true)
    end

    def test_does_not_allow_other_garbage
        assert_raise(ArgumentError) do
            TestModel.has_one(:tmhm,:blarg=>true)
        end
    end
end
