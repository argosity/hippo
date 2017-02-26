import React from 'react';

import SnapShot   from 'react-test-renderer';

import Settings from 'lanes/screens/system-settings';

import { getTestScreen } from '../test-models';


describe('SystemSettings Screen', () => {

    it('renders', () => {
        const settings = shallow(<Settings screen={getTestScreen()} />);
        console.log(settings.debug());

        /* expect(options.context.uistate.screenMenuPreference).toEqual('');
         * navbar.find('.screens-menu-toggle').simulate('click');
         * expect(options.context.uistate.screenMenuPreference).toEqual('menu-wide');
         * navbar.find('.screens-menu-toggle').simulate('click');
         * expect(options.context.uistate.screenMenuPreference).toEqual('menu-narrow');
         * navbar.find('.screens-menu-toggle').simulate('click');
         * expect(options.context.uistate.screenMenuPreference).toEqual('menu-hidden');*/
    });
});
