import React from 'react';
import { base as grommetTheme } from 'grommet/themes';
import PropTypes from 'prop-types';
import { action, observable } from 'mobx';
import { observer, inject, Provider } from 'mobx-react';
import { Router, Route, Switch } from 'react-router-dom';
import createBrowserHistory from 'history/createBrowserHistory';
import { RouterStore, syncHistoryWithStore } from 'mobx-react-router';
import { CirclePlay } from 'grommet-icons';
import { Grommet, Button } from 'grommet';
import Sidebar from 'react-sidebar';
import styled, { ThemeProvider } from 'styled-components';
import 'hippo/config-data';
import 'hippo/screen-definitions';
import User from '../user';
import Tenant from '../models/tenant';
import Extensions  from '../extensions';
import Menu        from './menu';
import Screen      from './screen';
import LoginDialog from '../access/login-dialog';
import SubscriptionChoiceLayer from '../access/subscription-choice-layer';
import Dimensions from './dimensions';
import './styles.scss';

function NoMatch({ match: { path } }) {
    const RootView = Extensions.controlling.rootView();
    if ('/' === path && RootView) {
        return <RootView />;
    }
    return (
        <h1 className="not-found">{path} was not found</h1>
    );
}

const SidebarToggle = styled(Button)`
    left: 0;
    z-index: 1;
    opacity: 0.2;
    bottom: 10px;
    position: fixed;
    transistion: all 0.4s;
    border-top-left-radius: 0;
    border-bottom-left-radius: 0;
    &:hover {
        opacity: 1.0;
    }
    ${props => props.isOpen && 'display: none;'}
`;

@inject('routing')
@observer
class Workspace extends React.Component {

    @observable sidebarOpen   = true;

    @observable sidebarDocked = false;

    mql = window.matchMedia(`(min-width: ${Dimensions.dockedWidthBreakpoint}px)`);

    static contextTypes = {
        theme: PropTypes.object,
    }

    constructor() {
        super();
        this.mql.addListener(this.onMediaQueryChanged);
        this.onMediaQueryChanged();
    }

    componentWillUnmount() {
        this.mql.removeListener(this.onMediaQueryChanged);
    }

    @action.bound
    onMediaQueryChanged() {
        this.sidebarDocked = this.mql.matches;
    }

    @action.bound
    onSetSidebarOpen(open) {
        this.sidebarOpen = open;
    }

    @action.bound
    toggleSidebarDocked() {
        this.sidebarOpen = !this.sidebarOpen;
    }

    get isDragSupported() {
        return Boolean('ontouchstart' in window);
    }

    renderOpenButton() {
        if (this.isDragSupported) { return null; }
        return (
            <SidebarToggle
                primary
                icon={<CirclePlay />}
                onClick={this.toggleSidebarDocked}
                isOpen={this.sidebarOpen}
            />
        );
    }

    renderSubscriptionChoice() {
        if (!User.isLoggedIn || Tenant.current.hasSubscription) { return null; }
        return <SubscriptionChoiceLayer />;
    }

    renderMenu() {
        return (
            <Menu
                currentPath={window.location.pathname}
                isOpen={this.sidebarOpen}
                isDocked={this.sidebarDocked}
                onCloseMenu={this.toggleSidebarDocked}
                onDockToggle={this.toggleSidebarDocked}
            />
        );
    }

    render() {
        return (
            <ThemeProvider theme={grommetTheme}>
                <Sidebar
                    styles={{ sidebar: { zIndex: 6 }, overlay: { zIndex: 5 } }}
                    sidebar={this.renderMenu()}
                    open={this.sidebarOpen}
                    docked={this.sidebarDocked}
                    onSetOpen={this.onSetSidebarOpen}
                >
                    <LoginDialog />
                    {this.renderSubscriptionChoice()}
                    {this.renderOpenButton()}

                    <Switch>
                        <Route
                            name='screen'
                            path="/:screenId/:identifier?"
                            component={Screen}
                        />
                        <Route component={NoMatch} />
                    </Switch>
                </Sidebar>
            </ThemeProvider>
        );
    }

}


class WorkspaceRoot extends React.Component {

    routing = new RouterStore();

    history = syncHistoryWithStore(createBrowserHistory(), this.routing);

    render() {
        return (
            <Grommet theme={grommetTheme}>
                <Provider routing={this.routing} history={this.history}>
                    <Router history={this.history}>
                        <Route path="/" component={Workspace} />
                    </Router>
                </Provider>
            </Grommet>
        );
    }

}

export default WorkspaceRoot;
