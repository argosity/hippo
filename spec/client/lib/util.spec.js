import * as Util from 'hippo/lib/util';

describe('Util helper functions', () => {
    it('dasherize', () => {
        expect(Util.dasherize('bar baz bing')).toEqual('bar-baz-bing');
    });

    it('titleize', () => {
        expect(Util.titleize('bar baz bing')).toEqual('Bar Baz Bing');
    });

    it('underscored', () => {
        expect(Util.underscored('bar baz bing')).toEqual('bar_baz_bing');
    });

    it('toSentence', () => {
        expect(Util.toSentence(['bar', 'baz', 'bing'])).toEqual('bar, baz and bing');
    });

    it('classify', () => {
        expect(Util.classify('bar baz bing')).toEqual('BarBazBing');
        expect(Util.classify('bar/baz-bing')).toEqual('Bar::BazBing');
    });

    it('isBlank', () => {
        expect(Util.isBlank(new Date('notdate'))).toBe(true);
        expect(Util.isBlank(new Date())).toBe(false);
        expect(Util.isBlank(-1 / 'r')).toBe(true);
        expect(Util.isBlank(/foo/)).toBe(false);
        expect(Util.isBlank(Util.isBlank)).toBe(false);
        expect(Util.isBlank(true)).toBe(false);
        expect(Util.isBlank(false)).toBe(false);
        expect(Util.isBlank(0)).toBe(true);
        expect(Util.isBlank(100)).toBe(false);
        expect(Util.isBlank({ a: 1 })).toBe(false);
        expect(Util.isBlank({})).toBe(true);
        expect(Util.isBlank('')).toBe(true);
        expect(Util.isBlank('test')).toBe(false);
        expect(Util.isBlank(undefined)).toBe(true);
        expect(Util.isBlank(null)).toBe(true);
    });

    it('renames properties', () => {
        expect(
            Util.renameProperties({ a: 1, b: 2, c: 3 }, { a: 'z', b: 'y' }),
        ).toEqual({ z: 1, y: 2, c: 3 });
    });
});
