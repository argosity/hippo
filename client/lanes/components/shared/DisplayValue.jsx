import React from 'react';

export default class DisplayValue extends React.Component {
    static mixins = [
        Lanes.Components.Form.FieldMixin
    ];
    static fieldClassName = 'display-value';
    renderEdit(props) {
        return (
            <BS.FormControl.Static {...props}>
                {this.fieldMixinGetValue()}
            </BS.FormControl.Static>
        );
    }
}
