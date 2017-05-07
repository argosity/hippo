import React from 'react';

import { Snapshot } from 'hippo/testing/screens';

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
        expect(Snapshot(<Settings screen={instance} />)).toMatchSnapshot();
    });
});
