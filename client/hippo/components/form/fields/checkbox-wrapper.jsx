import React from 'react';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import cn from 'classnames';
import { CheckBox } from 'grommet';

@observer
export default class CheckBoxWrapper extends React.Component {

    @action.bound onBlur(ev) {
        this.props.onBlur({ target: { value: ev.target.checked } });
    }
    @action.bound onChange({ target: { checked: value } }) {
        this.props.onChange({ target: { value } });
    }
    render() {
        const { className, ...props } = this.props;
        return (
            <CheckBox
                {...props}
                onChange={this.onChange}
                className={cn('checkbox', className)}
                onBlur={this.onBlur} checked={!!this.props.value} />
        );
    }

}
