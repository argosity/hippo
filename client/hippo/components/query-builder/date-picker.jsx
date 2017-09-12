import React from 'react';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import DateTime from '../date-time';

@observer
export default class DatePicker extends React.PureComponent {
    @action.bound onChange({ target: { value: dates } }) {
        this.props.clause.value = `${dates[0].toISOString()}...${dates[1].toISOString()}`;
    }

    render() {
        return (
            <DateTime
                format="M d Y"
                options={{ enableTime: false, mode: 'range' }}
                onChange={this.onChange}
            />
        );
    }
}
