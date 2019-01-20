import React from 'react'; // eslint-disable-line no-unused-vars
import PropTypes    from 'prop-types';
import { Tooltip } from 'react-tippy';
import 'react-tippy/dist/tippy.css';
import { CircleQuestion } from 'grommet-icons';

export default function Help({ message, ...ttProps }) {
    return (
        <Tooltip
            arrow
            title={message}
            {...ttProps}
        >
            <CircleQuestion />
        </Tooltip>
    );
}

Help.propTypes = {
    message: PropTypes.string.isRequired,
};
