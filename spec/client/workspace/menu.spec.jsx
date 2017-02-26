import React from 'react';
import { each, range } from 'lodash';

import Group      from 'lanes/screens/group';
import Menu       from 'lanes/workspace/menu';
import MenuGroup  from 'lanes/workspace/menu-group';
import MenuOption from 'lanes/workspace/menu-option';

import { Snapshot } from '../test-utils';
import { getTestScreen } from '../test-models';

describe('Workspace Menu', () => {
    beforeEach(() => {
        each(range(0, 5), i =>
            Group.register({ id: `group-${i}`, title: `Group # ${i}`, icon: `grp-${i}` }),
        );
    });

    it('renders with a logout button', () => {
        const menu = shallow(<Menu />);
        expect(menu).toHaveRendered('Logout');
    });

    it('renders groups', () => {
        const menu = shallow(<Menu />);
        expect(menu.find('Group').length).toEqual(5);
        expect(Snapshot(<Menu />)).toMatchSnapshot();
    });

    it('has groups with screens', () => {
        const group = shallow(<MenuGroup group={Group.all[0]} />);
        expect(group).not.toHaveRendered('MenuOption');

        getTestScreen({ id: 'new', group_id: Group.all[0].id });
        expect(group).toHaveRendered('MenuOption');
        expect(Snapshot(<MenuGroup group={Group.all[0]} />)).toMatchSnapshot();
    });

    it('has renders a menu option', () => {
        const screen = getTestScreen();
        const option = shallow(<MenuOption screen={screen} />);
        expect(option).toHaveRendered(`Anchor[path="/${screen.id}/"]`);
        expect(option).toHaveRendered(`Icon[type="${screen.icon}"]`);
        expect(Snapshot(<MenuOption screen={screen} />)).toMatchSnapshot();
    });
});
