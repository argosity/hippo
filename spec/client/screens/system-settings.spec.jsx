import React from 'react';

import { Snapshot } from '../test-utils';

import Settings from 'lanes/screens/system-settings';
import Instance from 'lanes/screens/instance';
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
