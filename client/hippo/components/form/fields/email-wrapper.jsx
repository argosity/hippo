import React from 'react';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import TextInput from 'grommet/components/TextInput';


@observer
export default class EmailWrapper extends React.Component {

    @action.bound focus() {
        this.inputRef.componentRef.focus();
    }

    @action.bound onChange(ev) {
        if (ev.target && ev.target.value) {
            ev.target.value = ev.target.value.replace(' ', '');
        }
        return this.props.onChange(ev);
    }

    render() {
        return (
            <TextInput
                ref={(f) => { this.inputRef = f; }}
                {...this.props}
                onDOMChange={this.onChange}
            />
        );
    }

}
