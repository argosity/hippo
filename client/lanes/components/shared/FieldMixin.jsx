import React from 'react';

if (!Lanes.Components.Form) { Lanes.Components.Form = {}; }


Lanes.Components.Form.FieldMixin = {

    registerForPubSub: false,

    bindEvents() {
        return (
            {model: `change:${this.props.name} remote-update:${this.props.name} invalid-fields invalid-field:${this.getInvalidFieldName()}`}
        );
    },

    mixins: [
        Lanes.React.Mixins.Access,
        Lanes.React.Mixins.ReadEditingState,
        Lanes.React.Mixins.FieldErrors
    ],

    propTypes: {
        model:     Lanes.PropTypes.State.isRequired,
        name:      React.PropTypes.string.isRequired,
        unlabeled: React.PropTypes.bool,
        fieldOnly: React.PropTypes.bool,
        onChange:  React.PropTypes.func,
        unstyled:  React.PropTypes.bool,
        getValue:  React.PropTypes.func,
        setValue:  React.PropTypes.func,
        align: React.PropTypes.oneOf([
            'right', 'left', 'center'
        ]),
        label: React.PropTypes.oneOfType([
            React.PropTypes.string, React.PropTypes.element
        ])
    },

    fieldMixinSetValue(ev) {
        if (this.props.onChange) {
            this.props.onChange(ev);
        }
        if (true !== __guardMethod__(ev, 'isDefaultPrevented', o => o.isDefaultPrevented())) {
            return (
                this.model[this.props.name] = ev.target.value
            );
        }
    },

    componentWillUnmount() {
        if (this.state.pendingChangeSetDelay) { return clearTimeout(this.state.pendingChangeSetDelay); }
    },

    _unsetChangeSet() {
        return (
            this.setState({displayChangeset: false, pendingChangeSetDelay: null})
        );
    },

    setModelState() {
        let pendingChangeSetDelay;
        const displayChangeset = this.model.updatingFromChangeset && this.model.changedAttributes()[this.props.name];
        if (displayChangeset && !this.state.pendingChangeSetDelay) {
            pendingChangeSetDelay = _.delay(this._unsetChangeSet, 2000);
        }
        return (
            this.setState({pendingChangeSetDelay, displayChangeset})
        );
    },

    _fieldMixinGetLabelValue() {
        return (
            __guardMethod__(this, 'getLabelValue', o => o.getLabelValue()) ||
                this.props.label ||
                _.titleize(_.humanize(this.props.name))
        );
    },

    fieldMixinGetValue() {
        const value = this.props.getValue ?
            this.props.getValue.call(this.model, this.props)
        : (this.props.value != null) ?
            this.props.value
        : this.getValue ?
            this.getValue()
        :
            this.model[this.props.name];
        if (_.isBlank(value)) {
            return (
                ''
            );
        } else {
            return (
                value
            );
        }
    },

    _fieldMixinRenderFormGroup(child, props, options) {
        let feedback, invalidMsg, label;
        if (invalidMsg = this.fieldInvalidValueMessage()) {
            feedback = [
                React.createElement(BS.FormControl.Feedback, {"key": "feedback"}),
                React.createElement(BS.HelpBlock, {"key": "help"}, (invalidMsg))
            ];
        }

        if (!this.props.unlabeled) {
            label =
                React.createElement(BS.ControlLabel, null,
                    (this._fieldMixinGetLabelValue())
                );
        }

        return (

            React.createElement(BS.Col, Object.assign({},  props),
                React.createElement(BS.FormGroup, {"validationState": (options.validationState)},
                    (label),
                    (child),
                    (feedback)
                )
            )

        );
    },

    _fieldMixinRenderEdit(props) {
        return (
            React.createElement(BS.FormControl, Object.assign({ 
                "type": (this.props.type || "text"),  
                "value": (this.fieldMixinGetValue())
                }, props
            ))
        );
    },

    _fieldMixinRenderDisplay(props) {
        let value = this.fieldMixinGetValue();
        if (_.isObject(value)) { value = value.toString(); }
        return (
            React.createElement(BS.FormControl.Static, null,
                (value)
            )
        );
    },


    _fieldMixinRenderNone(props) {
        const clean = LC.Form.FieldMixin.statics.cleanSizeProps(props);
        return (
            React.createElement("span", Object.assign({},  clean ))
        );
    },

    renderType() {
        if (this.isEditingRecord()) {
            if (this.hasWriteAccess()) {
                return (
                    ['edit', 'Edit']
                );
            } else if (this.hasReadAccess()) {
                return (
                    ['read-only', 'Display']
                );
            } else {
                return (
                    ['none', 'None']
                );
            }
        } else {
            if (this.hasReadAccess()) {
                return (
                    ['display', 'Display']
                );
            } else {
                return (
                    ['none', 'None']
                );
            }
        }
    },
    statics: {
        cleanSizeProps(props, comp) {
            if (comp == null) { comp = {}; }
            return (
                Lanes.u.cleanBsSizes( LC.Form.FieldMixin.statics.cleanColumnProps(props, comp) )
            );
        },

        cleanColumnProps(props, comp, ...xtra) {
            return (
                _.omit( props,  _.keys(comp.constructor.propTypes).concat([
                    'model', 'label', 'name', 'unlabeled', 'fieldOnly', 'placeholder',
                    'commands', 'query', 'editOnly', 'syncOptions', 'labelField', 'type',
                    'selectField', 'idField', 'queryModel', 'choices', 'align'
                ], xtra))
            );
        },

        renderEmptyColumn(props) {
            if (props == null) { ({ props } = this); }
            props = this.cleanColumnProps(props, this);
            return (
                React.createElement(BS.Col, Object.assign({},  props ))
            );
        }
    },

    render() {
        const [type, method] = Array.from(this.renderType());
        const options = {};

        const hasError = this.isFieldValueInvalid();
        if (hasError) { options.validationState = 'warning'; }
        const props = LC.Form.FieldMixin.statics.cleanColumnProps(this.props, this);

        props.export className = _.classnames(
            _.result(this, 'fieldClassName'),
            'lanes-field', type, props.export className,
            ( this.props.align ? `align-${this.props.align}` : null),
            {
                changeset: this.state.displayChangeset,
                'has-error': hasError
            }
        );
        const fieldProps = Lanes.u.cleanBsSizes(props);
        const field = (this[ `render${method}` ] || this[`_fieldMixinRender${method}`])(
            this.props.fieldOnly ? fieldProps : _.omit(fieldProps, 'export className')
        );
        if (this.props.fieldOnly) {
            return (
                field
            );
        } else {
            return (
                ( this['renderFormGroup'] || this['_fieldMixinRenderFormGroup'] )(field, props, options)
            );
        }
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