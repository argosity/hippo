import React from 'react';

export class FakeInputEvent {
    constructor(value) {
        this.target = {value};
    }
    isDefaultPrevented() { return false; }
}


export class RadioField extends React.Component {
    static mixins = [
        Hippo.Components.Form.FieldMixin
    ];
    handleRadioChange(ev) {
        if (ev.target.checked) {
            return (
                this.fieldMixinSetValue( new FakeInputEvent(this.props.value) )
            );
        }
    }

    renderEdit(props, handlers) {
        return (
            <BS.FormControl
                {...props}
                {...handlers}
                type="radio"
                checked={(this.props.checked != null) || (this.props.value === this.model[this.props.name])}
                onChange={this.handleRadioChange} />
        );
    }
}
