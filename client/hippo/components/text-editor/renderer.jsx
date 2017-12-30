import React from 'react'; // eslint-disable-line no-unused-vars
import PropTypes from 'prop-types';
import cn from 'classnames';

import './renderer.scss';

export default function TextEditorRenderer({ className, content }) {
    return (
        <div
            className={cn('text-editor-content', className)}
            dangerouslySetInnerHTML={{ __html: content }}
        />
    );
}

TextEditorRenderer.propTypes = {
    content: PropTypes.string.isRequired,
    className: PropTypes.string.isRequired,
};
