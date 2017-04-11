import React from 'react';

import PropTypes from 'prop-types';

export default class DateTime extends React.Component {
    static mixins = [
        Lanes.Components.Form.FieldMixin
    ];
    static fieldClassName = 'date-time';

    static propTypes = {
        unlabled: PropTypes.bool,
        format:   PropTypes.string
    };
    getDefaultProps() {
        return (
            {format: 'ddd, MMM Do YYYY, h:mm a'}
        );
    }


    handleKeyDown(ev) {
        if (ev.key === 'Enter') { return this.props.onEnter(); }
    }

    renderDisplay(props) {
        const clean = LC.Form.FieldMixin.statics.cleanSizeProps(props);
        return (
            <BS.FormControl.Static {...clean}>
                {this.getDateValue().format(this.props.format)}
            </BS.FormControl.Static>
        );
    }

    getDateValue() {
        return (
            _.moment.utc(this.fieldMixinGetValue())
        );
    }

    handleDateTimeChange(val) {
        return (
            this.fieldMixinSetValue({target: {value: Lanes.u.utcToLocalDate(val)}})
        );
    }

    renderEdit(props) {
        props = _.extend({
            ref:       'control',
            value:     Lanes.u.dateToUTC(this.getDateValue().toDate()),
            onChange:  this.handleDateTimeChange
        }, this.props);
        props = _.omit(LC.Form.FieldMixin.statics.cleanSizeProps(props), 'writable');
        return (
            <Lanes.Vendor.ReactWidgets.DateTimePicker {...props} />
        );
    }
}
