import React from 'react';
import { get } from 'lodash';
import { classify } from '../lib/util';

export default class DefaultComponentNotFound extends React.Component {

    static propTypes = {
        extension: React.PropTypes.shape({
            identifier: React.PropTypes.string,
        }),
    }

    render() {
        const identifier = get(this.props.extension, 'identifier', 'UnknownExtension');
        return (
            <div className="fancy-header">
                <h1>{classify(identifier)}.rootElement() did not return an element to render!</h1>
            </div>
        );
    }

}
