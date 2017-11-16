import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { computed } from 'mobx';
import { get } from 'lodash';
import cn from 'classnames';

import Button from 'grommet/components/Button';
import Spinning from 'grommet/components/icons/Spinning';
import SaveIcon from 'grommet/components/icons/base/Save';
import { BaseModel } from '../models/base';


@observer
export default class SaveButton extends React.Component {

    static propTypes = {
        busy: PropTypes.bool,
        model: PropTypes.instanceOf(BaseModel),
        busyLabel: PropTypes.string,
        label: PropTypes.string,
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
        return this.isBusy ? <Spinning /> : <SaveIcon />;
    }

    render() {
        // eslint-disable-next-line no-unused-vars
        const {
            label, icon, props: {
                label: _, busyLabel: __, busy, model: ___, ...props
            },
        } = this;

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
