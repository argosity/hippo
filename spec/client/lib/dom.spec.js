import dom from 'lanes/lib/dom';

describe('Dom helper functions', () => {
    let element;
    let $;
    const html = '<article class="foo"><section><p>foo</p><p>bar</p></section></article>';

    beforeEach(() => {
        element = document.createElement('div');
        $ = dom(element);
        $.html(html);
    });

    it('can select text', () => {
        expect(element).toEqual($[0]);
        expect($.find('p').text()).toEqual('foo');
    });

    it('can add class', () => {
        $.addClass('bar');
        expect($.hasClass('bar')).toEqual(true);
    });
});
