import { Box, Container } from '../test-models';
import { autorun, action, observable, computed } from 'mobx';

describe("Model Collection Test", () => {

    it('adds items specific for each model', () => {
        const collection = Box.Collection.create();
        expect(Box.identifiedBy).toEqual('test/box');
        collection.push({ width: 3, height: 3, depth: 3 });
        const box = collection[0];
        expect(box).toBeInstanceOf(Box);
        expect(box.volume).toBe(27);
    });

    it('has custom properties are observable', () => {
        const collection = Box.Collection.create();
        const spy = jest.fn();
        autorun(() => { spy(collection.lastServerMessage); });
        expect(spy).toHaveBeenCalledTimes(1);
        collection.lastServerMessage = 'test-2';
        expect(collection.lastServerMessage).toEqual('test-2');
        expect(spy).toHaveBeenCalledTimes(2);
        expect(spy).toHaveBeenLastCalledWith('test-2');
    });

    it('can fetch', () => {
        fetch.mockResponseOnce(JSON.stringify({ data: [{ width: 12, height: 12, depth: 10 }] }));
        Box.Collection.create().fetch().then((collection) => {
            expect(fetch).lastCalledWith(
                '/api/test/boxes.json',
                { headers: { 'Content-Type': 'application/json' } },
            );
            expect(collection.length).toEqual(1);
            expect(collection[0].volume).toBe(1440);
        });
    });

    it('can be initialized with models', () => {
        const collection = Box.Collection.create([{ width: 3, height: 3, depth: 3 }]);
        expect(collection[0].volume).toBe(27);
    });

    it('can set default attributes', () => {
        const collection = Box.Collection.create(
            [{ width: 3 }],
            { defaults: { label: 'paper box' } },
        );
        expect(collection[0].width).toBe(3); // doesn't overwrite
        collection.push({ });
        expect(collection[1].label).toEqual('paper box');
    });
});
