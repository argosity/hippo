import React from 'react'
import ReactDOM from 'react-dom'

export default class ReactComponentRenderer {

    constructor(klass, container) {
        this.klass = klass;
        this.container = container;
        this.props = {};
        this.component = null;
    }

    replaceProps(props, callback) {
        this.props = {};
        this.setProps(props, callback);
    }

    setProps(partialProps, callback) {
        if (this.klass == null) {
            console.warn(
                'setProps(...): Can only update a mounted or ' +
                    'mounting component. This usually means you called setProps() on ' +
                    'an unmounted component. This is a no-op.'
            );
            return;
        }
        Object.assign(this.props, partialProps);
        var element = React.createElement(this.klass, this.props);
        this.component = ReactDOM.render(element, this.container, callback);
    }

    unmount() {
        debugger
        ReactDOM.unmountComponentAtNode(this.container);
        this.klass = null;
    }
}
