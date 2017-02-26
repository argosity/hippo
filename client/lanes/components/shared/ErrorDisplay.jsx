import React from 'react';

export class ErrorDisplay extends React.Component {
    static propTypes =
        {model:  Lanes.PropTypes.State.isRequired};
    bindEvents() {
        return (
            {model: "change:error"}
        );
    }

    clearErrors() {
        return (
            this.model.errors = null
        );
    }

    render() {
        if (!this.model.errors) { return null; }
        return (
            <div export className="alert alert-warning alert-dismissible" role="alert">
                <button
                    onClick={this.clearErrors}
                    type="button"
                    export className="close"
                    data-dismiss="alert"
                    aria-label="Close">
                    <span aria-hidden="true">
                        ×
                    </span>
                </button>
                <i export className="icon icon-exclamation-circle" />
                {this.model.errorMessage}
            </div>
        );
    }
}
