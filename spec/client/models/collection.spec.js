import { autorun } from 'mobx';
import Sync from 'hippo/models/sync';
import SyncAdapter from 'hippo/models/sync-adapter';

import {
    BaseModel,
    identifiedBy,
    field, identifier, computed,
} from 'hippo/models/base';

@identifiedBy('test/box')
class Box extends BaseModel {

    @identifier id;

    @field({ type: 'number' }) width  = 1;

    @field height = 1;

    @field depth  = 1;

    @computed get volume() {
        return this.width * this.height * this.depth;
    }

}


describe('Model Collection Test', () => {
    beforeEach(() => {
        //        global.fetch = fetch;
    });

    it('can fetch', () => {
        const collection = Box.Collection.create();
        expect(collection.sync).toBeInstanceOf(SyncAdapter);
        expect(collection.sync.isBusy).toBe(false);

        Sync.setResponseData({
            success: true,
            data: [{ id: 1, height: 10, width: 10, depth: 5 }],
            message: 'success',
        });
        return collection.sync.fetch().then(() => {
            expect(Sync).toHaveBeenCalledWith('/api/test/box', {});
            expect(collection).toHaveLength(1);
            expect(collection[0].height).toEqual(10);
            expect(collection[0].width).toEqual(10);
            expect(collection[0].depth).toEqual(5);
            expect(collection[0].volume).toEqual(500);
        });
    });

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
        collection.sync.foo = 'bar';
        autorun(() => { spy(collection.sync.lastServerMessage); });
        expect(spy).toHaveBeenCalledTimes(1);
        collection.sync.lastServerMessage = 'test-2';
        expect(collection.sync.lastServerMessage).toEqual('test-2');
        expect(collection.sync.foo).toEqual('bar');
        expect(spy).toHaveBeenCalledTimes(2);
    });

    it('can be initialized with models', () => {
        const collection = Box.Collection.create([{ width: 3, height: 3, depth: 3 }]);
        expect(collection[0].volume).toBe(27);
    });

    it('can set default attributes', () => {
        const collection = Box.Collection.create(
            [{ width: 3 }],
            { defaults: { width: 12, height: 12 } },
        );
        expect(collection[0].width).toBe(3); // doesn't overwrite
        collection.push({ });
        expect(collection[1].height).toEqual(12);
    });
});
