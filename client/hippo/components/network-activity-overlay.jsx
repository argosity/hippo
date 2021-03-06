import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { autorun, action, observable, computed } from 'mobx';
import Spinning from 'hippo/components/icon/spinning';
import { CircleInformation } from 'grommet-icons';
import { delay, isEmpty, get } from 'lodash';
import classnames from 'classnames';
import styled from 'styled-components';
import { backgroundStyle, normalizeColor } from 'grommet/utils';


const StyledOverlay = styled.div`

position: absolute;
z-index: 11;
height: 100%;
width: 100%;
left: 0;
right: 0;
top: 0;
bottom: 0;

display: flex;
justify-content: center;
align-items: center;
span { margin-left: 1rem; }

.mask {
  background-color: white;
  top: 0;
  height: 100%;
  left: 0%;
  width: 100%;
  opacity: 0.8;
  position: absolute;
}

&.rounded {
  .mask { border-radius: 8px }
}

.message {
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
  box-shadow: 6px 7px 5px ${props => normalizeColor('neutral-4', props.theme)};
  background-color: ${props => backgroundStyle(props.color || 'brand', props.theme)};
  color: black;
  display:flex;
  align-items: center;
  width: 80%;
}`;

function Indicator({ error }) {
    return error ? <CircleInformation size="medium" /> : <Spinning size="large" />;
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
        if (this.props.method) {
            const pending = this.props.model.sync.pending[this.props.method];
            return Boolean(pending && pending.size);
        }
        return this.props.model.sync.isBusy;
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
                const method = get(model, 'sync.inProgressType');
                if ('fetch' === method) {
                    message = 'Loading…';
                } else if ('save' === method) {
                    message = 'Saving…';
                } else if ('delete' === method) {
                    message = 'Deleting…';
                } else {
                    message = 'Busy…';
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
