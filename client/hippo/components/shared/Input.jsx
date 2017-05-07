import React from 'react';

export default class Input extends React.Component {
    static mixins = [
        Hippo.Components.Form.InputFieldMixin
    ];
    renderInputField(props, handlers) {
        return (
            <BS.FormControl
                type={this.props.type || 'text'}
                {...props}
                {...handlers}
                onChange={this.fieldMixinSetValue} />
        );
    }
}
