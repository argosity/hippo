import { each, range } from 'lodash';

import Group      from 'hippo/screens/group';
import Screen     from 'hippo/screens/definition';
import Menu       from 'hippo/workspace/menu';
import MenuGroup  from 'hippo/workspace/menu-group';
import MenuOption from 'hippo/workspace/menu-option';

import { Snapshot } from 'hippo/testing/screens';
import { getTestScreen } from '../test-models';

describe('Workspace Menu', () => {
    beforeEach(() => {
        Group.enabled_group_ids = [];
        each(range(0, 5), (i) => {
            const gid = `group-${i}`;
            Group.enabled_group_ids.push(gid);
            Group.register({ id: gid, title: `Group # ${i}`, icon: `grp-${i}` });
            Screen.register({
                group_id: gid, icon: 'unknown', id: `screen-${i}`, title: `test screen for ${i}`
            });
        });
    });

    it('renders with a logout button', () => {
        const menu = shallow(<Menu />);
        expect(menu).toHaveRendered('Logout');
    });

    it('has groups with screens', () => {
        const group = shallow(<MenuGroup group={Group.all[0]} />);
        expect(group).not.toHaveRendered('MenuOption');
        getTestScreen({ id: 'new', group_id: Group.all[0].id });
        expect(Snapshot(<MenuGroup group={Group.all[0]} />)).toMatchSnapshot();
    });

    it('has renders menu options', () => {
        const screen = getTestScreen();
        const option = shallow(<MenuOption screen={screen} />);
        expect(option).toHaveRendered(`Anchor[path="/${screen.id}/"]`);
        expect(option).toHaveRendered(`Icon[type="${screen.icon}"]`);
        expect(Snapshot(<MenuOption screen={screen} />)).toMatchSnapshot();
    });
});
