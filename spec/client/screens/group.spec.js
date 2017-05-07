import ScreensGroup from 'hippo/screens/group';
import { autorun } from 'mobx';
import { getTestScreen } from '../test-models';

jest.mock('hippo/lib/request-assets');


describe('Screens Group', () => {
    afterEach(() => {
        ScreensGroup.all.clear();
    });

    it('can be registered', () => {
        const spy = jest.fn();
        ScreensGroup.all.clear();
        autorun(() => { spy(ScreensGroup.all.length); });
        const group = ScreensGroup.register({ id: 'test' });
        expect(ScreensGroup.all).toHaveLength(1);
        expect(ScreensGroup.all[0]).toEqual(group);
        expect(spy).toHaveBeenCalledTimes(2);
    });

    it('has observable screens', () => {
        const group = new ScreensGroup({ id: 'test' });
        expect(group.screens).toHaveLength(0);
        const spy = jest.fn();
        autorun(() => { spy(group.screens.length); });
        group.screens.push(getTestScreen());
        group.screens.push(getTestScreen());
        expect(group.screens).toHaveLength(2);
        expect(spy).toHaveBeenCalledTimes(3);
    });
});
