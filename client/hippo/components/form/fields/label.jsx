import React from 'react';
import { isString } from 'lodash';
import { observer } from 'mobx-react';
import Label from 'grommet/components/Label';

@observer
export default class LabelWrapper extends React.Component {

    render() {
        const { value, ...props } = this.props;
        return isString(value) ? <Label {...props}>{value}</Label> : value;
    }

}
