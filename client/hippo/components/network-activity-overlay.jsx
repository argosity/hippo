import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { autorun, action, observable, computed } from 'mobx';
import Spinning from 'hippo/components/icon/spinning';
import { CircleInformation } from 'grommet-icons';
import { delay, isEmpty, includes, get } from 'lodash';
import classnames from 'classnames';
import styled from 'styled-components';
import { backgroundStyle } from 'grommet/utils/styles';
import color from 'grommet/utils/colors';


const StyledOverlay = styled.div`

    .network-activity-overlay {
        position: absolute;
        z-index: 11;
        height: 100%;
        width: 100%;
        left: 0;
        right: 0;
        top: 0;
        bottom: 0;
      .mask {
          background-color: white;
          height: 100%;
          left: 0;
          opacity: 0.8;
          position: absolute;
          top: 0;
          width: 100%;
      }

            &.rounded {
          .mask { border-radius: 8px }
            }

      .message {
          width: 450px;
          max-width: 90%;
          min-height: 65px;
          line-height: 3rem;
          border-width: ${props => props.theme.button.border.width};
          border-color: ${props => props.theme.button.border.color};
          border-style: solid;
          margin-left: auto;
          margin-right: auto;
          font-size: 2rem;
          position: relative;
          top: 25%;
          border-radius: 8px;
          padding: 10px;
          box-shadow: 6px 7px 5px ${props => color.colorForName('neutral-4', props.theme)};
          background-color: ${props => backgroundStyle(props.color || 'brand', props.theme)}
    display: flex;
    justify-content: center;
    align-items: center;
    span { margin-left: 1rem; }
  }

}
`;

function Indicator({ error }) {
    return error ? <CircleInformation size="medium" /> : <Spinning size="medium" />;
}

@observer
export default class NetworkActivityOverlay extends React.Component {

    static defaultProps = {
        timeout: 30000,
        errorTimeout: 2000,
    }

    static propTypes = {
        model:   PropTypes.object,
        message: PropTypes.string,
        timeout: PropTypes.number,
        visible: PropTypes.bool,
        method:  PropTypes.string,
        errorTimeout: PropTypes.number,
    }

    @computed get isRequesting() {
        const { syncInProgress } = this.props.model || {};
        if (this.props.method) {
            return !!(syncInProgress && syncInProgress.method === this.props.method);
        }
        return !!syncInProgress;
    }

    @computed get hasError() {
        return this.props.model && !isEmpty(this.props.model.errors);
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
                message = get(model, 'errorMessage', 'Error');
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
            <StyledOverlay className={classes}>
                <div className="mask">
                    <div className="message">
                        <Indicator error={this.hasError} />
                        <span>{this.message}</span>
                    </div>
                </div>
            </StyledOverlay>
        );
    }

}
