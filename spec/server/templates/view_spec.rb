require_relative "../spec_helper"

describe Hippo::Templates::View do

    it 'renders erb templates' do
        view = Hippo::Templates::View.new(foo: 'Foo', bar: 'Bar')
        expect(view.variables).to eq(:foo=>"Foo", :bar=>"Bar")
        expect(view).to receive(:source) { '<%= foo %> is <%= bar %>' }
        expect(view.as_html).to eq('Foo is Bar')
    end

end
