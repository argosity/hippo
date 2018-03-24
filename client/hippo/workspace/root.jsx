import React from 'react';
import cn from 'classnames';
import PropTypes from 'prop-types';
import { action, observable } from 'mobx';
import { observer, inject, Provider } from 'mobx-react';
import { Router, Route, Switch } from 'react-router-dom';
import createBrowserHistory from 'history/createBrowserHistory';
import { RouterStore, syncHistoryWithStore } from 'mobx-react-router';
import { CirclePlay } from 'grommet-icons';
import { Grommet, Button } from 'grommet';
import Sidebar from 'react-sidebar';
import { ThemeProvider } from 'styled-components';
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


@inject('routing')
@observer
class Workspace extends React.Component {

    static contextTypes = {
        theme: PropTypes.object,
    }

    @observable sidebarOpen   = true;
    @observable sidebarDocked = false;

    constructor() {
        super();
        this.mql = window.matchMedia(`(min-width: ${Dimensions.dockedWidthBreakpoint}px)`);
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
            <Button
                primary
                icon={<CirclePlay />}
                onClick={this.toggleSidebarDocked}
                className={cn('sidebar-toggle', { 'is-open': this.sidebarOpen })}
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
            <ThemeProvider theme={this.context.theme}>
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
            <Grommet>
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
