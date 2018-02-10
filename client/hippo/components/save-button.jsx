import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { computed, action } from 'mobx';
import { get } from 'lodash';
import cn from 'classnames';

import Button from 'grommet/components/Button';
import Spinning from 'hippo/components/icon/spinning';
import { Save } from 'grommet-icons';
import { BaseModel } from '../models/base';


@observer
export default class SaveButton extends React.Component {

    static propTypes = {
        busy: PropTypes.bool,
        model: PropTypes.instanceOf(BaseModel),
        busyLabel: PropTypes.string,
        label: PropTypes.string,
        saveOnClick: PropTypes.bool,
    }

    static defaultProps = {
        label: 'Save',
        busyLabel: 'Saving…',
    }

    @computed get isBusy() {
        return this.props.busy || get(this.props, 'model.syncInProgress.isUpdate');
    }

    @computed get label() {
        return this.isBusy ? this.props.busyLabel : this.props.label;
    }

    @computed get icon() {
        return this.isBusy ? <Spinning /> : <Save />;
    }

    @action.bound saveModel() {
        this.props.model.save();
    }

    render() {
        // eslint-disable-next-line no-unused-vars
        const {
            label, icon, props: {
                saveOnClick, label: _, busyLabel: __, busy, model: ___, ...props
            },
        } = this;

        if (saveOnClick) {
            props.onClick = this.saveModel;
        }

        return (
            <Button
                {...props}
                primary
                className={cn('save-button', this.props.className)}
                icon={icon}
                disabled={busy}
                label={label}
            />
        );
    }

}
