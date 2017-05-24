require_relative "spec_helper"

describe Hippo::Strings do

    # just 'cuz
    Str = Hippo::Strings

    def test_random_is_of_proper_length
        assert_equal 12, Str.random.length
        assert_equal 6, Str.random(6).length
    end

    it 'random_doesnt_use_bad_chars' do
        bad = Str::BAD_RAND_CHARS
        expect(bad).to be_present
        0.upto(10).each do | i |
            string = Str.random
            string.each_char do |c|
                expect(bad).to_not include(c)
            end
        end
    end

    it 'shortens code_identifier' do
        # if all words are long engouth to shorten, then it takes an
        # equal number from each
        expect('GENACMCORP').to eq(Str.code_identifier('General Acme Corp'))
        # If one word is too short, it'll attempt to make up the difference with
        # later words
        expect('GENIINCORP').to eq(Str.code_identifier('General I Incorporated'))
        # If it gets to the end and it's still too short, it'll append the
        # padding char
        expect('GENERALIBC').to eq(Str.code_identifier('General I BC'))
        expect('GENERALIB*').to eq(Str.code_identifier('General I B.', padding: '*'))
        expect('FSANSEYEAG').to eq(Str.code_identifier('Four score and seven years ago', padding: '*'))
        expect('ALONSBEAST').to eq(Str.code_identifier('A long s beasty'))
        expect('GE').to eq(Str.code_identifier( 'GE', padding: false ))
        expect('HI33ME').to eq(Str.code_identifier('Hi 33 Me!', padding: false))
        expect('BADIANDOCO').to eq(Str.code_identifier("Bayer, Dickinson and O'Conner", padding: false))
    end
end
