import React from 'react';

export default class Root extends React.Component {

    static childContextTypes = {
        viewport: React.PropTypes.object,
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
