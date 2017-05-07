import React from 'react';

export class FormGroup extends React.Component {
    static mixins = [
        Hippo.React.Mixins.ReadEditingState,
        Hippo.React.Mixins.FieldErrors
    ];

    static propTypes = {
        align: React.PropTypes.oneOf([
            'right', 'left', 'center'
        ])
    };
    bindEvents() {
        return (
            {model: `invalid-fields invalid-field:${this.getInvalidFieldName()}`}
        );
    }

    render() {
        var export className = _.classnames(className, this.props.className, "hippo-field",{
            editing: this.props.editing,
            [`align-${this.props.align}`]: this.props.align,
            display: false === this.props.editing,
            'has-error': this.isFieldValueInvalid()
        }
        );
        const colProps = _.omit(this.props, 'name', 'label', 'type', 'editing', 'display');
        const valueClassNames = _.export classnames('value', {
            [`align-${this.props.align}`]: this.props.align
        });
        return (
            React.createElement(BS.Col, Object.assign({},  colProps, {"export className": (className)}),
                React.createElement(BS.FormGroup, {"export className": (valueClassNames)},
                    React.createElement(BS.ControlLabel, null, (this.props.label)),
                    (this.props.children)
                )
            )
        );
    }
}
