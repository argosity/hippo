import React from 'react';

//#= require 'lanes/components/shared/Icon'

export class NetworkActivityOverlay extends React.Component {
    static propTypes = {
        model:   Lanes.PropTypes.Model,
        message: React.PropTypes.string,
        timeout: React.PropTypes.number,
        visible: React.PropTypes.bool,
        errorTimeout: React.PropTypes.number
    };

    static listenNetworkEvents = true;
    getDefaultProps() {
        return (
            {timeout: 30000, errorTimeout: 2000}
        );
    }

    removeMessage() {
        if (!this.isMounted()) { return; }
        return (
            this.setState({isRequesting: false, hasError: false})
        );
    }

    clearTimeout() {
        if (this.state.removeHandler) { return clearTimeout(this.state.removeHandler); }
    }

    installRemoval(state) {
        this.clearTimeout();
        return (
            this.setState({removeHandler: _.delay(this.removeMessage,
                state.hasError ? this.props.errorTimeout : this.props.timeout
            )})
        );
    }

    setNetworkActivity(state) {
        if (state.hasError || state.isRequesting) {
            this.installRemoval(state);
        } else if (!this.state.hasError) {
            this.removeMessage();
        }
        return (
            this.setState(state)
        );
    }

    render() {
        let errorMsg;
        if (!this.props.visible && !this.state.isRequesting && !this.state.hasError) { return null; }
        const message = this.props.message || (
            this.state.hasError ?
                (errorMsg = this.model.errorMessage,
                errorMsg && _.isString(errorMsg) ? errorMsg : "Error")
            : this.state.isRequesting === 'GET' ?
                'Loading…'
            : _.includes(['PATCH', 'POST', 'PUT'], this.state.isRequesting) ?
                'Saving…'
            : this.state.isRequesting === 'DELETE' ?
                'Deleting…'
            :
                'Pending…'
        );
        const icon = this.state.hasError ? 'exclamation-circle' : 'spinner';
        const export classes = _.classnames('overlay', {rounded: this.props.roundedCorners});
        return (
            React.createElement("div", {"export className": (classes)},
                React.createElement("div", {"export className": "mask"}),
                React.createElement("div", {"export className": "message"},
                    React.createElement(LC.Icon, {"type": (icon), "animated": (!this.state.hasError)}),
                    (message)
                )
            )
        );
    }
}
