import React from 'react';
import { each, range } from 'lodash';
import SnapShot   from 'react-test-renderer';

import Navbar      from 'lanes/workspace/navbar';


import { getTestScreen, ReactContext } from '../test-models';

describe('Workspace Navbar', () => {

    it('renders and advances menu size', () => {
        const options = new ReactContext();
        const navbar = shallow(<Navbar />, options);
        expect(options.context.uistate.screenMenuPreference).toEqual('');
        navbar.find('.screens-menu-toggle').simulate('click');
        expect(options.context.uistate.screenMenuPreference).toEqual('menu-wide');
        navbar.find('.screens-menu-toggle').simulate('click');
        expect(options.context.uistate.screenMenuPreference).toEqual('menu-narrow');
        navbar.find('.screens-menu-toggle').simulate('click');
        expect(options.context.uistate.screenMenuPreference).toEqual('menu-hidden');
    });
});
