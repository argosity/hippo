import React from 'react';
import { observer } from 'mobx-react';

@observer
export default class TextAreaWrapper extends React.PureComponent {

    render() {
        return (
            <textarea
                {...this.props}
            />
        );
    }

}
