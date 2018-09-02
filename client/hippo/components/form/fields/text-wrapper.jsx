import React from 'react';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import { TextInput } from 'grommet';

@observer
export default class TextWrapper extends React.Component {

    @action.bound focus() {
        this.inputRef.componentRef.focus();
    }

    @action.bound onSelect({ suggestion }) {
        this.props.onChange({ target: { value: suggestion } });
    }

    render() {
        const inputProps = this.props;
        return (
            <TextInput
                ref={(f) => { this.inputRef = f; }}
                onSelect={this.onSelect}
                {...inputProps} onInput={this.props.onChange}
            />
        );
    }

}
