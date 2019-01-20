import { autorun, observe } from 'mobx';
import Sync from 'hippo/models/sync';
import moment from 'moment';
import { Ship, Container, Box } from '../test-models';

describe('BaseModel Test', () => {
    it('translates assignments to a hasMany field into reset()', () => {
        const container = new Container();
        const originalBoxes = container.boxes;
        container.boxes = [
            { width: 42 },
        ];
        expect(container.boxes).toBe(originalBoxes);
    });

    it('translates assignments of a belongsTo', () => {
        const boat = new Ship({ name: 'BOATY', container: { name: 'box-1' } });
        expect(boat.container).toBeInstanceOf(Container);
        expect(boat.container.name).toEqual('box-1');
        expect(boat.container.vessel).toBe(boat);
        boat.container = { name: 'Ceci n’est pas une récipient' };
        expect(boat.container).toBeInstanceOf(Container);
        expect(boat.container.name).toEqual('Ceci n’est pas une récipient');
        expect(boat.container.vessel).toBe(boat);
        boat.container = null;
    });

    it('sets isNew depending on primary Key', () => {
        const box = new Box();
        expect(box.identifier).toEqual(undefined);
        expect(box.isNew).toBe(true);
        box.id = 42;
        expect(box.id).toEqual(42);
        expect(box.isNew).toBe(false);
    });

    it('rejects unsettable', () => {
        const box = new Box({ bad: 1 });
        expect(box.bad).toBeUndefined();
        box.update({ bad: 22 });
        expect(box.bad).toBeUndefined();
    });

    it('validates and records "type" in schema', () => {
        const box = Box.deserialize({ width: '23' });
        expect(Box.propertyOptions.width.type).toEqual('number');
        expect(box.width).toEqual(23);
    });

    it('generates an error message from errors', () => {
        const box = new Box();
        expect(box.sync.errorMessage).toEqual('');
        Sync.setResponseData({
            success: false,
            data: { id: 1, height: 10, width: 10, depth: 5 },
            errors: { foo: 'cannot be blank', baz: 'is very invalid' },
        });
        return box.sync.save().then(() => {
            expect(box.sync.errorMessage)
                .toEqual('Foo cannot be blank and Baz is very invalid');
        });
    });

    it('uses momentjs for dates', () => {
        const ship = Ship.deserialize({ sail_date: '2012-11-14T01:03:42.415Z' });
        expect(moment.isMoment(ship.sail_date)).toBe(true);
        expect(ship.sail_date.toISOString()).toEqual('2012-11-14T01:03:42.415Z');
    });


    describe('sync', () => {
        it('computes the syncUrl', () => {
            const box = new Box({ id: 11, width: 5 });
            const spy = jest.fn();
            autorun(() => spy(box.sync.url));
            expect(spy).toHaveBeenCalledWith('/api/test/box/11');
            expect(box.id).toEqual(11);
            expect(box.identifierFieldValue).toEqual(11);
            expect(box.isNew).toEqual(false);
            expect(box.sync.url).toEqual('/api/test/box/11');
            box.id = 42;
            expect(spy).toHaveBeenCalledTimes(2);
            expect(spy).toHaveBeenCalledWith('/api/test/box/42');
            expect(box.sync.url).toEqual('/api/test/box/42');
        });

        it('is set from sync', () => {
            const box = new Box({ id: 11, width: 5 });
            expect(box.sync.data).toEqual({
                id: 11, height: 1, depth: 1, width: 5,
            });
            const spy = jest.fn();
            observe(box.sync, 'data', spy);
            box.sync.data = { id: 2 };
            expect(spy).toHaveBeenCalled();
        });

        it('sets isBusy', () => {
            Sync.setResponseData({
                success: true,
                message: 'fetch worked!',
                data: { id: 1, height: 10, width: 10, depth: 5 },
            });
            const box = new Box({ id: 11, width: 5 });
            box.fetch();
            expect(box.sync.isPending).toEqual(true);
            // const spy = jest.fn();
            // autorun(() => spy(box.sync.url));
        });
    });
});
