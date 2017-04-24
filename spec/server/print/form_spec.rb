require_relative '../spec_helper'


describe "Printing tempaltes" do

    class TestPrinter < Lanes::Templates::Latex
        model ::Lanes::User
        extension_id :lanes
        identifier :foo
        def root_path
            Pathname.new(__FILE__).dirname.join('../../fixtures')
        end
        def layout
        end
    end

    it "can generate a pdf" do
        user = FactoryGirl.create(:user)
        tmpl = TestPrinter.new(user.id)
        tmpl.record
        expect(tmpl.render.length).to be > 1000
    end

    it "can find templates by id" do
        expect(Lanes::Templates::Latex.for_identifier(:foo)).to eq(TestPrinter)
    end


end
