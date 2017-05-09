import React from 'react';
import classnames from 'classnames';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import PropTypes from 'prop-types';
import Sidebar from 'grommet/components/Sidebar';
import Heading from 'grommet/components/Heading';
import Footer  from 'grommet/components/Footer';
import Header  from 'grommet/components/Header';
import Anchor  from 'grommet/components/Anchor';
import Menu from 'grommet/components/Menu';
import Group   from './menu-group';
import Screens from '../screens';
import Icon from '../components/icon';

import User from '../user';

//const On

@observer
class Logout extends React.PureComponent {


    static contextTypes = {
        router: PropTypes.object,
    }

    @action.bound
    onLogoutClick(ev) {
        ev.stopPropagation();
        ev.preventDefault();
        User.logout();
        const { router } = this.context;
        router.push('/');
    }

    render() {
        if (!User.isLoggedIn) { return null; }
        return (
            <Menu direction="column" align="start" justify="between" primary>
                <Header align="end" pad={{ horizontal: 'medium' }}>
                </Header>
                <Anchor label="Log Out" onClick={this.onLogoutClick}>
                    Log Out
                </Anchor>
            </Menu>
        );
    }

}

@observer
export default class WorkspaceMenu extends React.Component {

    render() {
        return (
            <Sidebar
                full size="small" separator="right"
                colorIndex="brand"
            >
                <Header justify="between" size="large" pad={{ horizontal: 'medium' }}>
                    Logo
                </Header>
                {Screens.activeGroups.map(g => <Group key={g.id} group={g} />)}

                <Logout />

            </Sidebar>
        );
    }
}