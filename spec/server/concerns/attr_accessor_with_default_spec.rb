require "lanes/spec_helper"

describe "Attr Accessor With Default" do

    Shared = Struct.new(:value)

    class AttrTestClass
        include Lanes::Concerns::AttrAccessorWithDefault
        attr_accessor_with_default :as_proc, Proc.new{ 42 }
        attr_accessor_with_default :non_copying, ->{ "default string" }
        attr_accessor_with_default :shared, Shared.new('default')
        attr_accessor_with_default :non_shared, ->{ Shared.new('default') }
        attr_accessor_with_default :startingnil
    end

    class Inherited<AttrTestClass
        non_shared "Foo"
    end

    it "sets up access" do
        a = AttrTestClass.new
        b = AttrTestClass.new

        expect(b.as_proc).to be(42)

        expect(b.non_copying).to eq("default string")

        b.non_copying = "A new string"

        expect(a.non_copying).to eq("default string")
        a.non_copying = "third value"
        expect(b.non_copying).to eq("A new string")

        expect(a.shared.value).to eq("default")
        expect(b.shared.value).to eq("default")

        a.shared.value = "a new value"

        expect(a.shared.value).to eq("a new value")
        expect(b.shared.value).to eq("a new value")

        a.non_shared.value = "a new value"
        expect(a.non_shared.value).to eq("a new value")
        expect(b.non_shared.value).to eq("default")
    end

    def test_inheritance
        a = Inherited.new
        b = AttrTestClass.new
        expect(a.non_shared).to be_a(String)
        expect(b.non_shared).to be_a(String)
        expect(a.non_shared.value).to eq("Foo")
        expect(b.non_shared.value).to eq("default")
    end

    def test_nils
        a = AttrTestClass.new
        expect( a.startingnil ).to be_nil
        a.startingnil = 22
        expect(aa.startingnil).to eq(22)
    end

end
