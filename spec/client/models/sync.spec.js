import Sync from 'hippo/models/sync';
import Config from 'hippo/config';
import { Box } from '../test-models';

jest.unmock('hippo/models/sync');

describe('Network sync', () => {
    beforeEach(() => {
        Config.api_host = '';
    });

    it('makes a request', () => {
        fetch.mockResponseOnce(JSON.stringify({ access_token: '12345' }));
        Sync.perform('/foo')
            .then((json) => {
                expect(json).toEqual({ access_token: '12345' });
            });
        expect(fetch).toHaveBeenCalledWith(
            '/foo.json',
            { headers: { 'Content-Type': 'application/json' } },
        );
    });

    it('makes request using options', () => {
        Sync.perform('/foo', { fields: ['test'] });
        expect(fetch).lastCalledWith('/foo.json?f%5B%5D=test', expect.any(Object));
        Sync.perform('/foo', { with: 'test' });
        expect(fetch).lastCalledWith('/foo.json?w=test', expect.any(Object));
        Sync.perform('/foo', { query: { bar: 'baz' } });
        expect(fetch).lastCalledWith('/foo.json?q%5Bbar%5D=baz', expect.any(Object));
    });

    it('sets a models value', () => {
        fetch.mockResponseOnce(JSON.stringify({ data: { width: 12, height: 12, depth: 10 } }));
        const box = new Box({ width: 5 });
        expect(box.width).toEqual(5);
        Sync.forModel(box, 'GET').then(() => expect(box.width).toEqual(12));
    });

    it('saves a model', () => {
        fetch.mockResponseOnce(JSON.stringify({ data: { width: 12, height: 12, depth: 10 } }));
        const box = new Box({ id: 11, width: 5 });
        const body = JSON.stringify(box.syncData);
        Sync.forModel(box).then(() => expect(box.width).toEqual(12));
        expect(fetch).lastCalledWith(
            '/api/test/box/11.json',
            { body, headers: { 'Content-Type': 'application/json' }, method: 'PUT' },
        );
    });
});
