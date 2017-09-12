import React from 'react';
import { observer } from 'mobx-react';
import { action, computed } from 'mobx';
import Select from 'grommet/components/Select';
import { get, find } from 'lodash';

@observer
export default class SelectFieldWrapper extends React.PureComponent {

    @action.bound
    onSelectChange({ value: { id } }) {
        const ev = { target: { value: id } };
        this.props.onChange(ev);
        this.props.onBlur(ev);
    }

    @computed get value() {
        return this.props.value ? get(find(this.props.collection, { id: this.props.value }), 'label', '') : '';
    }
    render() {
        const { collection, ...otherProps } = this.props;
        return (
            <Select
                {...otherProps}
                value={this.value}
                options={collection}
                onChange={this.onSelectChange}
            />
        );
    }

}
