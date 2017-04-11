import React from 'react';

import PropTypes from 'prop-types';

export default class Root extends React.Component {

    static childContextTypes = {
        viewport: PropTypes.object,
    }

    getChildContext() {
        return (
            {viewport: this.props.viewport}
        );
    }

    render() {
        return (
            <div className="root">
                {this.props.children}
            </div>
        );
    }
}
