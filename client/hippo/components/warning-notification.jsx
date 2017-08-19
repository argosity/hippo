import React from 'react'; // eslint-disable-line no-unused-vars
import PropTypes from 'prop-types';
import Notification from 'grommet/components/Notification';

export default function WarningNotification(props) {
    if (!props.message) { return null; }
    return (
        <Notification message={props.message} size="small" status="warning" />
    );
}

WarningNotification.propTypes = {
    message: PropTypes.string,
};
