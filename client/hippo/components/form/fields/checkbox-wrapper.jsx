import React from 'react';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import CheckBox from 'grommet/components/CheckBox';

@observer
export default class CheckBoxWrapper extends React.PureComponent {

    @action.bound onBlur(ev) {
        this.props.onBlur({ target: { value: ev.target.checked } });
    }
    @action.bound onChange({ target: { checked: value } }) {
        this.props.onChange({ target: { value } });
    }
    render() {
        return (
            <CheckBox
                {...this.props} onChange={this.onChange}
                onBlur={this.onBlur} checked={!!this.props.value} />
        );
    }

}
