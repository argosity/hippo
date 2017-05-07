import React from 'react';

export class FakeNumberEvent {
    constructor(value) {
        value = _.isNull(value) ? 0 : value;
        this.target = {value};
    }
    isDefaultPrevented() { return false; }
}

export class NumberInput extends React.Component {
    static mixins = [
        Hippo.Components.Form.InputFieldMixin
    ];
    handleNumberChange(n) {
        return (
            this.fieldMixinSetValue( new FakeNumberEvent(n) )
        );
    }

    renderInputField(props, handlers) {

        if (!props.format) { props.format = '#,###.00'; }
        props = _.omit(props, 'label');

        return (

            <Hippo.Vendor.ReactWidgets.NumberPicker
                ref="select"
                {...handlers}
                {...props}
                onChange={this.handleNumberChange}
                value={Number(props.value)} />

        );
    }
}
