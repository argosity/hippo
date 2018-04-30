import React from 'react'; // eslint-disable-line no-unused-vars
import Settings from 'hippo/screens/system-settings';
import Instance from 'hippo/screens/instance';
import { getTestScreen } from '../test-models';


describe('SystemSettings Screen', () => {
    let definition;
    let instance;

    beforeEach(() => {
        definition = getTestScreen();
        instance = new Instance({ definition, isActive: true });
    });

    it('renders', () => {
        const settings = mount(<Settings screen={instance} />);
        expect(settings).toHaveRendered('Screen');
        settings.unmount();
    });
});
