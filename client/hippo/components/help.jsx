import React from 'react'; // eslint-disable-line no-unused-vars
import PropTypes    from 'prop-types';
import { Tooltip } from 'react-tippy';
import 'react-tippy/dist/tippy.css';
import CircleQuestionIcon from 'grommet/components/icons/base/CircleQuestion';

export default function Help({ message, ...ttProps }) {
    return (
        <Tooltip
            arrow
            title={message}
            {...ttProps}
        >
            <CircleQuestionIcon colorIndex="brand" />
        </Tooltip>
    );
}

Help.propTypes = {
    message: PropTypes.string.isRequired,
};
