require_relative "spec_helper"

describe Hippo::Numbers do

    Num = Hippo::Numbers

    it "has percnum" do
        expect(Num::PercNum.new('5%'  ).is_percentage?).to eq true
        expect(Num::PercNum.new('5%' ).is_percentage?).to eq true
        expect(Num::PercNum.new('5.3 %' ).is_percentage?).to eq true
        expect(Num::PercNum.new('$5.3').is_percentage?).to eq false
        # this is debatable, but we have to draw the line somewhere
        expect(Num::PercNum.new( '%5.3' ).is_percentage?).to eq false

        expect('95.0').to eq(Num::PercNum.new( '5'  ).debit_from(100).to_s)
        expect('95.0').to eq(Num::PercNum.new( '5%' ).debit_from(100).to_s)
        expect('105.0').to eq(Num::PercNum.new( '5%' ).credit_to(100).to_s)
        expect('95.0').to eq(Num::PercNum.new( '-5%').credit_to(100).to_s)

        expect('137.38449').to eq(Num::PercNum.new( '33.383%' ).credit_to(103).to_s)
        expect('68.61551').to eq(Num::PercNum.new( '33.383%' ).debit_from(103).to_s)
    end

end
