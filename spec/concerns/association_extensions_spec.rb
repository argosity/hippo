require "lanes/spec_helper"


class AssociationExtensionsTest < Lanes::TestCase

    include TestingModels

    def test_adding_event_listener_requires_inverse
        err = assert_raise(ArgumentError) do
            TestModel.has_one(:tmhm,:listen=>{:save=>:on_save})
        end
        assert_match( /does not have an inverse_of specified./, err.message )
    end

    def test_adds_listener
        Tmhm.belongs_to(:tm)
        TestModel.has_one(:tmhm,:listen=>{:save=>:on_tmhm_save}, :inverse_of=>:tm)
        tm = TestModel.new
        tm.expects(:on_tmhm_save)
        tm.build_tmhm
        assert tm.save
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
