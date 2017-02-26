import React from 'react';
import classnames from 'classnames';
import { observer } from 'mobx-react';

import Sidebar from 'grommet/components/Sidebar';
import Heading from 'grommet/components/Heading';
import Header  from 'grommet/components/Header';
import Footer  from 'grommet/components/Footer';

import Anchor  from 'grommet/components/Anchor';

import Group   from './menu-group';
import Screens from '../screens';
import Icon from '../components/icon';

import User from '../user';

const OnLogoutClick = (ev) => {
    debugger
    ev.stopPropagation();
    ev.preventDefault();
    User.logout();
}

function Logout() {
    return (
        <Anchor label="Log Out" onClick={OnLogoutClick}>
            <Heading tag="h3" margin="none" strong>
                Log Out
            </Heading>
        </Anchor>
    );
}

export default class WorkspaceMenu extends React.Component {
    /* renderGroup(group) {
     *     return (
     *         <ScreenGroup {...this.props} model={group} key={group.id} />
     *     );
     * }

     * logOut(ev) {
     *     ev.preventDefault();
     *     return (
     *         Lanes.current_user.logout()
     *     );
     * }*/

    render() {
        return (
            <Sidebar
                full size="small" separator="right"
                colorIndex="brand"
            >
                <Header justify="between" size="large" pad={{ horizontal: 'medium' }}>
                    Logo
                </Header>
                {Screens.groups.map(g => <Group key={g.id} group={g} />)}
                <Footer size="large" primary pad={{ horizontal: 'medium' }}>
                    <Logout />
                </Footer>
            </Sidebar>
        );
    }
}

/*
 *
 * <div className="screens-menu">
 * <div className="screens-menu-content">
 * <ul className="navigation">
 * {Screens.groups.map(g => <Group key={g.id} group={g} />)}
 * </ul>
 * </div>
 * <ul className="navigation">
 * <li
 * className="group logout"
 * data-tooltip-message="Log Out"
 * data-placement="right"
 * >
 * <Logout />
 * </li>
 * </ul>
 * </div>*/
