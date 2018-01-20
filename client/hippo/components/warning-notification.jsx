import React from 'react'; // eslint-disable-line no-unused-vars
import PropTypes from 'prop-types';
import Notification from './notification';

export default function WarningNotification(props) {
    if (!props.message) { return null; }
    return (
        <Notification size="small" status="warning"  {...props} />
    );
}

WarningNotification.propTypes = {
    message: PropTypes.string,
};
