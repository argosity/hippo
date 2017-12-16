import React from 'react';

import { action, observable } from 'mobx';
import { observer } from 'mobx-react';
import cn from 'classnames';
import {
    BrowserRouter as Router,
    Route,
    Switch,
} from 'react-router-dom';
import App from 'grommet/components/App';
import Sidebar from 'react-sidebar';
import 'hippo/config-data';
import 'hippo/screen-definitions';
import Button from 'grommet/components/Button';
import CirclePlayIcon from 'grommet/components/icons/base/CirclePlay';
import User from '../user';
import Tenant from '../models/tenant';
import Extensions  from '../extensions';
import Menu        from './menu';
import Screen      from './screen';
import LoginDialog from '../access/login-dialog';
import SubscriptionChoiceLayer from '../access/subscription-choice-layer';

import './styles.scss';

const DOCKED_WIDTH_BREAKPOINT = 950;

function NoMatch({ match: { path } }) {
    const RootView = Extensions.controlling.rootView();
    if ('/' === path && RootView) {
        return <RootView />;
    }
    return (
        <h1 className="not-found">{path} was not found</h1>
    );
}

@observer
class Workspace extends React.Component {

    @observable sidebarOpen   = true;
    @observable sidebarDocked = false;

    constructor() {
        super();
        this.mql = window.matchMedia(`(min-width: ${DOCKED_WIDTH_BREAKPOINT}px)`);
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
                icon={<CirclePlayIcon />}
                onClick={this.toggleSidebarDocked}
                className={cn('sidebar-toggle', { 'is-open': this.sidebarOpen })}
            />
        );
    }

    renderSubscriptionChoice() {
        if (!User.isLoggedIn || Tenant.current.hasSubscription) { return null; }
        return <SubscriptionChoiceLayer />;
    }

    render() {
        return (
            <App centered={false}>
                <LoginDialog />
                {this.renderSubscriptionChoice()}
                <Sidebar
                    styles={{ sidebar: { zIndex: 60 }, overlay: { zIndex: 59 } }}
                    sidebar={<Menu
                        isOpen={this.sidebarOpen}
                        isDocked={this.sidebarDocked}
                        onCloseMenu={this.toggleSidebarDocked}
                        onDockToggle={this.toggleSidebarDocked} />
                    }
                    open={this.sidebarOpen}
                    docked={this.sidebarDocked}
                    onSetOpen={this.onSetSidebarOpen}
                >
                    {this.renderOpenButton()}

                    <Switch>
                        <Route name='screen' path="/:screenId/:identifier?" component={Screen} />
                        <Route component={NoMatch} />
                    </Switch>
                </Sidebar>
            </App>
        );
    }

}

export default function WorkspaceRoot() {
    return (
        <Router>
            <Route path="/" component={Workspace} />
        </Router>
    );
}
