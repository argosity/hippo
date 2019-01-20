import React from 'react';
import PropTypes from 'prop-types';
import { get, bindAll } from 'lodash';

import Config from '../config';
import Extensions from '../extensions';

function Logo() {
    const url = get(Config, 'system_settings.logo.thumbnail_url');
    const title = get(Extensions, 'controlling.title');
    return url
        ? <img alt={`${title} Logo`} src={`//${Config.api_host}${url}`} /> : <span>{title}</span>;
}

export default class Navbar extends React.Component {

    static contextTypes = {
        uistate: PropTypes.object.isRequired,
    }

    constructor(props) {
        super(props);
        bindAll(this, 'switchMenu');
    }

    switchMenu(ev) {
        if (ev) { ev.preventDefault(); }
        this.context.uistate.nextSidebarState();
    }

    render() {
        return (
            <div className="header-top">
                <div className="navbar-header">
                    <div className="navbar-brand logo"><Logo /></div>
                    <button className="screens-menu-toggle" onClick={this.switchMenu} type="button">
                        <span className="sr-only">
                                Toggle navbar
                        </span>
                        <i className="icon" />
                    </button>
                </div>
            </div>
        );
    }

}
