import React from 'react';
import { isString } from 'lodash';
import { observer } from 'mobx-react';

@observer
export default class LabelWrapper extends React.Component {

    render() {
        const { value, ...props } = this.props;
        return isString(value) ? <label {...props}>{value}</label> : value;
    }

}
