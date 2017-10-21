import React from 'react';
import PropTypes from 'prop-types';
import { observer, PropTypes as MobxPropTypes } from 'mobx-react';
import { autorun, action, observable, computed } from 'mobx';
import Spinning from 'grommet/components/icons/Spinning';
import CircleInformationIcon from 'grommet/components/icons/base/CircleInformation';
import { delay, isEmpty, includes, get } from 'lodash';
import classnames from 'classnames';
import './network-activity-overlay.scss';

function Indicator({ error }) {
    return error ? <CircleInformationIcon size="medium" /> : <Spinning size="medium" />;
}

@observer
export default class NetworkActivityOverlay extends React.PureComponent {

    static defaultProps = {
        timeout: 30000,
        errorTimeout: 2000,
    }

    static propTypes = {
        model:   MobxPropTypes.observableObject,
        message: PropTypes.string,
        timeout: PropTypes.number,
        visible: PropTypes.bool,
        method:  PropTypes.string,
        errorTimeout: PropTypes.number,
    }

    @computed get isRequesting() {
        const { syncInProgress } = this.props.model;
        if (this.props.method) {
            return !!(syncInProgress && syncInProgress.method === this.props.method);
        }
        return !!syncInProgress;
    }

    @computed get hasError() {
        return !isEmpty(this.props.model.errors);
    }

    @computed get isVisible() {
        return this.props.visible || this.isPending;
    }

    @observable isPending = false;

    removeHandler = null;

    @action.bound
    removeMessage() {
        this.isPending = false;
    }

    clearTimeout() {
        if (this.removeHandler) {
            clearTimeout(this.removeHandler);
            this.removeHandler = null;
        }
    }

    installRemoval() {
        this.clearTimeout();
        this.removeHandler = delay(
            this.removeMessage, (this.hasError ? this.props.errorTimeout : this.props.timeout),
        );
    }

    componentWillMount() {
        this.loadingObserverDisposer = autorun(() => {
            if (this.hasError || this.isRequesting) {
                this.isPending = true;
                this.installRemoval();
            } else if (!this.hasError) {
                this.isPending = false;
            }
        });
    }

    componentWillUnMount() {
        this.loadingObserverDisposer();
        this.clearTimeout();
    }

    get message() {
        const { props: { model } } = this;
        let { message } = this.props;
        if (!message) {
            if (this.hasError) {
                message = model.errorMessage || 'Error';
            } else {
                const method = get(model, 'syncInProgress.method');
                if ('GET' === method) {
                    message = 'Loading…';
                } else if (includes(['PATCH', 'POST', 'PUT'], method)) {
                    message = 'Saving…';
                } else if ('DELETE' === method) {
                    message = 'Deleting…';
                }
            }
        }
        return message || 'Pending…';
    }

    render() {
        if (!this.isVisible) { return null; }

        const classes = classnames('network-activity-overlay', this.props.className, {
            rounded: this.props.roundedCorners,
        });

        return (
            <div className={classes}>
                <div className="mask">
                    <div className="message">
                        <Indicator error={this.hasError} />
                        <span>{this.message}</span>
                    </div>
                </div>
            </div>
        );
    }

}
