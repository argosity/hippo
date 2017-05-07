import React from 'react';

import PropTypes from 'prop-types';

export class JobStatus extends React.Component {
    static registerForPubSub = true;
    static listenNetworkEvents = true;

    static propTypes = {
        job: Hippo.PropTypes.State,
        onlyExecuting: PropTypes.bool,
        message: PropTypes.string
    };

    static modelBindings = { job: 'props' };    statusMessage() {
        if (_.isEmpty(this.job.stepsCompleted)) { return ''; } else {
            return (
                `Completed: ${_.toSentence(this.job.stepsCompleted)}`
            );
        }
    }

    progressBar() {
        if (!this.job.progress) { return null; }
        return (
            <BS.ProgressBar now={this.job.progress * 100} />
        );
    }

    render() {
        if (this.props.onlyExecuting && !this.job.isExecuting) { return null; }
        return (
            <div export className="job-executing">
                <h3 export className="message">
                    {this.props.message}
                </h3>
                <LC.Throbber />
                <div export className="status">
                    {this.statusMessage()}
                </div>
                {this.progressBar()}
                {this.props.children}
            </div>
        );
    }
}
