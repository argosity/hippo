require_relative '../spec_helper'

class AttrAccessorWithDefaultTest < Lanes::TestCase

    Shared = Struct.new(:value)

    class AttrTestClass
        include Lanes::Concerns::AttrAccessorWithDefault
        attr_accessor_with_default :as_proc, Proc.new{ 42 }
        attr_accessor_with_default :non_copying, ->{ "default string" }
        attr_accessor_with_default :shared, Shared.new('default')
        attr_accessor_with_default :non_shared, ->{ Shared.new('default') }
    end

    class Inherited<AttrTestClass
        non_shared "Foo"
    end

    def test_access
        a = AttrTestClass.new
        b = AttrTestClass.new

        assert_equal 42, b.as_proc

        assert_equal "default string", b.non_copying

        b.non_copying = "A new string"

        assert_equal "default string", a.non_copying
        a.non_copying = "third value"
        assert_equal "A new string", b.non_copying


        assert_equal "default", a.shared.value
        assert_equal "default", b.shared.value

        a.shared.value = "a new value"

        assert_equal "a new value", a.shared.value
        assert_equal "a new value", b.shared.value

        a.non_shared.value = "a new value"
        assert_equal "a new value", a.non_shared.value
        assert_equal "default", b.non_shared.value
    end

    def test_inheritance
        a = Inherited.new
        b = AttrTestClass.new
        assert_kind_of String, a.non_shared
        assert_kind_of Shared, b.non_shared
        assert_equal "Foo", a.non_shared
        assert_equal "default", b.non_shared.value
    end


end
