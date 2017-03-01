import React from 'react';

Lanes.Components.Form.InputFieldMixin = {

    mixins: [
        Lanes.Components.Form.FieldMixin
    ],

    propTypes: {
        onlyNumeric:  React.PropTypes.bool,
        selctOnFocus: React.PropTypes.bool,
        onEnter: React.PropTypes.func
    },

    focus() {
        return (
            _.dom(this, 'input').el.focus()
        );
    },

    getDefaultProps() {
        return (
            {type: 'text'}
        );
    },

    handleKeyDown(ev) {
        if (ev.key === 'Enter') { return this.props.onEnter(); }
    },

    selectOnFocus(ev) {
        return (
            ev.target.select()
        );
    },

    onFieldBlur() {
        this.onFieldInteraction();
        return (
            __guardMethod__(this.props, 'onBlur', o => o.onBlur())
        );
    },

    renderEdit(props) {
        props = _.extend(props, {
            ref: 'input',
            name: this.props.name,
            value: this.fieldMixinGetValue()
        });

        const handlers = { onBlur: this.onFieldBlur };

        if (this.props.onEnter) {         handlers.onKeyDown = this.handleKeyDown; }
        if (this.props.selectOnFocus) {   handlers.onFocus   = this.selectOnFocus; }

        props = Lanes.u.cleanBsSizes(props);

        return (

            this.renderInputField(props, handlers)

        );
    }
};

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return (
        transform(obj, methodName)
    );
  } else {
    return (
        undefined
    );
  }
}