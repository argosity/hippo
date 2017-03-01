import React from 'react';

export default class IndeterminateCheckbox extends React.Component {
    componentDidMount() { return this.updateIndeterminate(); }
    componentDidUpdate() { return this.updateIndeterminate(); }

    updateIndeterminate() {
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

    render() {
        return (
            <input
                type="checkbox"
                {...this.props}
                checked={this.props.checked}
                onChange={this.props.onChange} />
        );
    }
}
