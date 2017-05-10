import { autorun, observe } from 'mobx';
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

    it('computes the syncUrl', () => {
        const box = new Box({ id: 11, width: 5 });
        const spy = jest.fn();
        autorun(() => spy(box.syncUrl));
        expect(spy).toHaveBeenCalledWith('/api/test/boxes/11');
        expect(box.id).toEqual(11);
        expect(box.identifierFieldValue).toEqual(11);
        expect(box.isNew).toEqual(false);
        expect(box.syncUrl).toEqual('/api/test/boxes/11');
        box.id = 42;
        expect(spy).toHaveBeenCalledTimes(2);
        expect(spy).toHaveBeenCalledWith('/api/test/boxes/42');
        expect(box.syncUrl).toEqual('/api/test/boxes/42');
    });

    it('is set from sync', () => {
        const box = new Box({ id: 11, width: 5 });
        expect(box.syncData).toEqual({ id: 11, height: 1, depth: 1, width: 5 });
        const spy = jest.fn();
        observe(box, 'syncData', spy);
        box.syncData = { id: 2 };
        expect(spy).toHaveBeenCalled();
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
        const box = new Box();
        box.id = 23;
        expect(Box.propertyOptions.id.type).toEqual('number');
        expect(() => (box.id = 'red')).toThrow('Bad Type');
        expect(box.id).toEqual(23);

        const container = new Container();
        container.id = 'test';
        expect(() => (container.id = 42)).toThrow('Bad Type');
        expect(container.id).toEqual('test');
    });

    it('generates an error message from errors', () => {
        const box = new Box();
        expect(box.errorMessage).toEqual('');
        box.errors = { foo: 'cannot be blank', baz: 'is very invalid' };
        expect(box.errorMessage).toEqual('Foo cannot be blank and Baz is very invalid');
    });
});
