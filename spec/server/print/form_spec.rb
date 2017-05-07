require_relative '../spec_helper'


describe "Printing tempaltes" do

    class TestPrinter < Hippo::Templates::Latex
        model ::Hippo::User
        extension_id :hippo
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
        expect(Hippo::Templates::Latex.for_identifier(:foo)).to eq(TestPrinter)
    end


end
