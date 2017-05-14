import React from 'react';
import PropTypes from 'prop-types';
import cn from 'classnames';
import { observable, action, computed } from 'mobx';
import { observer } from 'mobx-react';
import { delay } from 'lodash';

import './master-detail.scss';

const DELAY_TIME = 500;

@observer
export default class MasterDetail extends React.PureComponent {


    static propTypes = {
        master: PropTypes.element.isRequired,
        detail: PropTypes.element,
    }

    @observable detailVisible;

    componentWillUnmount() {
        if (this.pendingDefer) { this.clearTimeout(this.pendingDefer); }
    }

    @action.bound
    setVisible(val) {
        this.pendingDefer = delay(() => {
            this.pendingDefer = null;
            this.detailVisible = val;
        }, DELAY_TIME);
    }

    setVisible
    componentWillReceiveProps(nextProps) {
        if (this.props.detail && !nextProps.detail) {
            this.setVisible(false);
        } else if (!this.props.detail && nextProps.detail) {
            this.setVisible(true);
        }
    }

    @computed get className() {
        return cn('master-detail-wrapper', {
            'detail-visible': this.detailVisible,
            'has-detail': this.props.detail,
            'detail-removed': this.detailVisible && !this.props.detail,
        });
    }

    render() {
        return (
            <div
                className={this.className}
            >
                <div className="master">
                    {this.props.master}
                </div>
                <div className="detail">
                    {this.props.detail}
                </div>
            </div>
        );
    }
}
