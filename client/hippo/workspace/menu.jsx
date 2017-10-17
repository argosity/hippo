import React from 'react';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import { isEmpty, get } from 'lodash';
import PropTypes from 'prop-types';
import Box     from 'grommet/components/Box';
import Button from 'grommet/components/Button';
import CloseIcon from 'grommet/components/icons/base/Close';
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
class Logout extends React.PureComponent {

    static contextTypes = {
        router: PropTypes.object,
    }

    @action.bound
    onLogoutClick(ev) {
        ev.stopPropagation();
        ev.preventDefault();
        User.logout();
        this.context.router.history.push('/');
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
export default class WorkspaceMenu extends React.PureComponent {

    renderUnGrouped() {
        if (!User.isLoggedIn || isEmpty(Screens.unGrouped)) { return null; }
        return (
            <Menu direction="column" align="start" justify="between" primary>
                {Screens.unGrouped.map(s => <MenuOption key={s.id} screen={s} />)}
            </Menu>
        );
    }

    renderClose() {
        if (this.props.isOpen && !this.props.isDocked) {
            return <Button icon={<CloseIcon />} onClick={this.props.onCloseMenu} plain />;
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
                {Screens.activeGroups.map(g => <Group key={g.id} group={g} />)}
                {this.renderUnGrouped()}
                <Logout />
            </Box>
        );
    }

}
