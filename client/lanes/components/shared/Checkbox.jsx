import React from 'react';

export class FakeInputEvent {
    constructor(value) {
        this.target = {value};
    }
    isDefaultPrevented() { return false; }
}


export class Checkbox extends React.Component {
    static propTypes =
        {supportIndeterminate: React.PropTypes.bool};

    static mixins = [
        Lanes.Components.Form.InputFieldMixin
    ];
    componentDidMount() { return this.updateIndeterminate(); }
    componentDidUpdate() { return this.updateIndeterminate(); }

    updateIndeterminate() {
        if (!this.props.supportIndeterminate) { return; }
        return (
            _.dom(this).el.indeterminate =
                (this.props.checked !== true) && (this.props.checked !== false)
        );
    }

    handleCheckboxChange(ev) {
        if (ev.target.checked) {
            return (
                this.fieldMixinSetValue( new FakeInputEvent(this.props.value) )
            );
        }
    }

    renderInputField(props, handlers) {
        return (
            <input
                type="checkbox"
                {...handlers}
                {...props}
                checked={this.props.checked}
                onChange={this.handleCheckboxChange} />
        );
    }
}