import React from 'react';
import Notification from 'grommet/components/Notification';

export default function WarningNotification(props) {
    if (!props.message){ return null; }
    return (
        <Notification message={props.message} size="small" status="warning" />
    );
}

WarningNotification.propTypes = {
    message: React.PropTypes.string
};
