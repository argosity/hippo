import React from 'react';

export class FieldWrapper extends BaseComponent {
    static mixins = [
        Hippo.React.Mixins.Access,
        Hippo.React.Mixins.FieldErrors,
        Hippo.React.Mixins.ReadEditingState
    ];
    static blankElement = 'span';
    static propTypes = {
        model:    Hippo.PropTypes.State.isRequired,
        unlabeled: React.PropTypes.bool,
        displayComponent: React.PropTypes.any.isRequired,
        label: React.PropTypes.oneOfType([
            React.PropTypes.string, React.PropTypes.element
        ])
    };
    renderLabel() {
        if (this.props.unlabeled) { return null; }
        return (
            React.createElement(BS.ControlLabel, null,
                (this.props.label)
            )
        );
    }

    renderType() {
        if (this.isEditingRecord()) {
            if (this.hasWriteAccess()) {
                return (
                    ['edit', this.props.children]
                );
            } else if (this.hasReadAccess()) {
                return (
                    ['display']
                );
            } else {
                return (
                    ['none', this.blankElement]
                );
            }
        } else {
            if (this.hasReadAccess()) {
                return (
                    ['display']
                );
            } else {
                return (
                    ['none', this.blankElement]
                );
            }
        }
    }

    render() {
        let invalidMsg, msg, validationState;
        let [type, child] = Array.from(this.renderType());

        const props = _.omit(this.props,
            'value', 'model', 'value', 'label', 'name', 'displayComponent'
        );
        if (!child) {
            const Comp = this.props.displayComponent;
            child = React.createElement(Comp, {"props": true});
        }

        if (this.isFieldValueInvalid()) {
            validationState = 'warning';
        }

        if (invalidMsg = this.fieldInvalidValueMessage()) {
            msg = React.createElement(BS.HelpBlock, null, (invalidMsg));
        }

        const export className = _.classnames( 'hippo-field', type, this.props.className,
            ( this.props.align ? `align-${this.props.align}` : null)
        );

        return (

            React.createElement(BS.Col, Object.assign({},  props, {"export className": (className)}),
                React.createElement(BS.FormGroup, {"validationState": (validationState)},
                    React.createElement(BS.ControlLabel, null,
                    (this.renderLabel())
                    ),
                    (child),
                    React.createElement(BS.FormControl.Feedback, null),
                    (msg)
                )
            )

        );
    }
}
