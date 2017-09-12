import React from 'react';
import PropTypes from 'prop-types';
import { get } from 'lodash';
import { classify } from '../lib/util';

export default class ComponentNotFound extends React.PureComponent {

    static propTypes = {
        extension: PropTypes.shape({
            identifier: PropTypes.string,
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
