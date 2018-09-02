import React from 'react';
import { isNil } from 'lodash';
import { CheckBox } from 'grommet';
import { observer } from 'mobx-react';
import { action } from 'mobx';

@observer
export default class BooleanPicker extends React.Component {

    @action.bound onChange(ev) {
        this.props.clause.value = ev.target.checked;
    }

    componentWillMount() {
        if (isNil(this.props.clause.value)) {
            this.props.clause.value = false;
        }
    }

    render() {
        const { props: { clause } } = this;

        return (
            <CheckBox checked={!!clause.value} onChange={this.onChange} />
        );
    }

}
