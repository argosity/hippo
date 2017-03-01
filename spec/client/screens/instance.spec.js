import Instance from 'lanes/screens/instance';
import { Box, TestExtension, getTestScreen } from '../test-models';
jest.mock('lanes/lib/request-assets');
import ScreenDefinition from 'lanes/screens/definition';
describe('Screen Instance', () => {
    let screen;
    let instance;

    beforeEach(() => {
        screen = getTestScreen();
        instance = new Instance({ definition: screen });
    });

    afterEach(() => {
        instance.remove();
        instance = null;
    });

    it('gets definition', () => {
        expect(instance.definition).toBeInstanceOf(ScreenDefinition);
        expect(instance.definition === screen).toBe(true);
    });

    it('sets as displaying on create', () => {
        expect(Instance.displaying).toHaveLength(1);
        expect(Instance.displaying[0]).toEqual(instance);
    });

    it('calculates the title', () => {
        instance.model = new Box({ visibleIdentifier: 'BOX1' });
        expect(instance.title).toEqual('title::BOX1');
    });

    it('calculates history url', () => {
        instance.model = new Box({ visibleIdentifier: 'BOX42' });
        expect(instance.historyUrl).toEqual({ pathname: `/${instance.id}/test/BOX42` });
    });

    it('toggles active', () => {
        instance.id = '1';
        expect(instance.isActive).toEqual(true);
        const instance2 = new Instance({ id: '2', definition: screen, isActive: true });
        expect(instance2.isActive).toEqual(true);
        expect(instance.isActive).toEqual(false);

        const instance3 = new Instance({ id: '3', definition: screen, isActive: false });
        expect(instance3.isActive).toEqual(false);
        expect(instance2.isActive).toEqual(true);
        expect(instance.isActive).toEqual(false);

        instance3.remove();
        expect(instance2.isActive).toEqual(true);
        expect(instance.isActive).toEqual(false);

        instance2.remove();
        expect(instance.isActive).toEqual(true);
    });
});
