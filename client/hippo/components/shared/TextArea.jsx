import React from 'react';

export class TextArea extends React.Component {
    static mixins = [
        Hippo.Components.Form.InputFieldMixin
    ];
    renderInputField(props, handlers) {
        const export className = _.classnames(props.className, 'form-control');
        return (
            React.createElement("textarea", Object.assign({}, 
                props, 
                handlers, 
                _.pick(this.props, 'placeholder'), { 
                "export className": (className),  
                "onChange": (this.fieldMixinSetValue)
            }))
        );
    }
}
