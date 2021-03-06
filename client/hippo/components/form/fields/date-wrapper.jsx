import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { action, observable } from 'mobx';
import moment from 'moment';
import DateTime  from '../../date-time';

@observer
export default class DateWrapper extends React.Component {

    static defaultProps = {
        format: 'M/d/Y h:iK',
    }

    static childContextTypes = { onDropChange: PropTypes.func }

    @observable isSelecting;

    @observable dateValue;

    getChildContext() {
        return { onDropChange: this.onDropChange };
    }

    @action.bound onDropChange(active) {
        const ev = { target: { value: moment(this.dateValue, this.props.format, true).toDate() } };
        if (this.isSelecting && !active) {
            this.props.onBlur(ev);
        }
        this.isSelecting = active;
    }

    @action.bound onDateChange({ target: { value } }) {
        this.dateValue = value;
        this.props.onChange({ target: { value } });
    }

    @action.bound onBlur(ev) {
        this.dateValue = moment(ev.target.value, this.props.format).toDate();
        const event = { target: { value: this.dateValue } };
        this.props.onChange(event);
        this.props.onBlur(event);
    }

    render() {
        return (
            <DateTime
                {...this.props}
                onChange={this.onDateChange}
                onBlur={this.onBlur}
            />
        );
    }

}
