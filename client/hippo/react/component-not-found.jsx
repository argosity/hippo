import React from 'react'; // eslint-disable-line no-unused-vars
import PropTypes from 'prop-types';
import { get } from 'lodash';
import { classify } from '../lib/util';

export default function ComponentNotFound(props) {
    const identifier = get(props.extension, 'identifier', 'UnknownExtension');
    return (
        <div className="fancy-header">
            <h1>{classify(identifier)}.rootElement() did not return an element to render!</h1>
        </div>
    );
}

ComponentNotFound.propTypes = {
    extension: PropTypes.shape({
        identifier: PropTypes.string,
    }),
};
