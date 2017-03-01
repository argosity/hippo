import React from 'react';
import { each, range } from 'lodash';

import Tabs, { ScreenTab } from 'lanes/workspace/tabs';
import Instance    from 'lanes/screens/instance';

import { getTestScreen } from '../test-models';
import { Context, Snapshot } from '../test-utils';

const addTab = () =>
    new Instance({ definition: getTestScreen() });

describe('Workspace Navbar', () => {
    beforeEach(() => {
        each(range(0, 3), addTab);
    });

    it('renders and adds/removes tabs', () => {
        const options = new Context();
        const tabs = shallow(<Tabs />, options);
        expect(tabs.find('ScreenTab').length).toEqual(3);
        addTab();
        expect(tabs.find('ScreenTab').length).toEqual(4);
        Instance.displaying[2].remove();
        expect(tabs.find('ScreenTab').length).toEqual(3);
        expect(Snapshot(<Tabs />)).toMatchSnapshot();
    });

    it('renders a tab', () => {
        const options = new Context();
        const screen = Instance.displaying[2];
        const tab = shallow(<ScreenTab screen={screen} />, options);
        expect(tab).toHaveRendered(`Tab[title="${screen.title}"]`);
        expect(Snapshot(<ScreenTab screen={Instance.displaying[2]} />)).toMatchSnapshot();
    });
});
