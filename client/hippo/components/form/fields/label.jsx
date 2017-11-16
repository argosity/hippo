import React from 'react';
import { observer } from 'mobx-react';
import Value from 'grommet/components/Value';

@observer
export default class LabelWrapper extends React.Component {

    render() {
        const { value }  = this.props;

        return (
            <Value value={value} />
        );
    }

}
