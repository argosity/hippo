import React from 'react';
import { observer } from 'mobx-react';
import { action, computed, observe } from 'mobx';
import { isEmpty, get } from 'lodash';
import PropTypes from 'prop-types';
import Box     from 'grommet/components/Box';
import Button from 'grommet/components/Button';
import { Close } from 'grommet-icons';
import Header  from 'grommet/components/Header';
import Anchor  from 'grommet/components/Anchor';
import Menu from 'grommet/components/Menu';
import Icon from '../components/icon';
import Group   from './menu-group';
import Screens from '../screens';
import MenuOption from './menu-option';
import User from '../user';
import Config from '../config';
import Asset from '../models/asset';

@observer
class Logout extends React.Component {

    static contextTypes = {
        router: PropTypes.object,
    }

    componentWillUnmount() {
        this.stopObserving();
    }

    componentWillMount() {
        this.stopObserving = observe(
            User, 'isLoggedIn', (change) => {
                if (change.oldValue && !change.newValue) {
                    this.context.router.history.replace('/');
                }
            },
        );
    }

    @action.bound
    onLogoutClick(ev) {
        ev.stopPropagation();
        ev.preventDefault();
        User.logout();
    }

    render() {
        if (!User.isLoggedIn) { return null; }
        return (
            <Menu direction="column" align="start" justify="between" primary>
                <Anchor label="Log Out" onClick={this.onLogoutClick}>
                    <Icon name="sign-out" />
                    Log Out
                </Anchor>
            </Menu>
        );
    }

}

const Logo = observer(() => {
    if (!get(Config, 'logo.thumbnail')) {
        if (!isEmpty(Config.product_name)) {
            return <Box className="product-name">{Config.product_name}</Box>;
        }
        return null;
    }
    return (
        <Box className="logo"><img src={Asset.urlForSize(Config.logo, 'thumbnail')} /></Box>
    );
});

@observer
export default class WorkspaceMenu extends React.Component {

    renderUnGrouped() {
        if (!User.isLoggedIn || isEmpty(Screens.unGrouped)) { return null; }
        return (
            <Menu direction="column" align="start" justify="between" primary>
                {Screens.unGrouped.map(s =>
                    <MenuOption
                        onSelection={this.onMenuSelection}
                        key={s.id} screen={s} />)}
            </Menu>
        );
    }

    @action.bound onMenuSelection() {
        if (this.canClose) { this.props.onCloseMenu(); }
    }

    @computed get canClose() {
        return (this.props.isOpen && !this.props.isDocked);
    }

    renderClose() {
        if (this.canClose) {
            return <Button icon={<Close />} onClick={this.props.onCloseMenu} plain />;
        }
        return null;
    }

    render() {
        return (
            <Box
                full size="small" separator="right"
                colorIndex="brand"
                className="screen-selection-menu"
            >
                <Header justify="between" size="large" pad={{ horizontal: 'medium' }}>
                    <Logo />
                    {this.renderClose()}
                </Header>
                {Screens.activeGroups.map(g =>
                    <Group
                        key={g.id}
                        group={g}
                        onMenuSelection={this.onMenuSelection}
                    />)}
                {this.renderUnGrouped()}
                <Logout />
            </Box>
        );
    }

}
