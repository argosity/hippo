import React from 'react';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import TextInput from 'grommet/components/TextInput';


@observer
export default class TextWrapper extends React.PureComponent {

    @action.bound focus() {
        this.inputRef.componentRef.focus();
    }
    render() {
        return (
            <TextInput
                ref={f => (this.inputRef = f)}
                {...this.props} onDOMChange={this.props.onChange}
            />
        );
    }

}
