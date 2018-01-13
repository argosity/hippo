import React from 'react'; // eslint-disable-line no-unused-vars
import PropTypes from 'prop-types';
import classnames from 'classnames';

import {
    StatusGood, StatusCritical, StatusWarning,
    StatusDisabled,
    StatusUnknown,
} from 'grommet-icons';

const CLASS_ROOT = 'status-icon';

export default function StatusIcon({
    className, size, value, ...props
}) {
    const classes = classnames(
        {
            [`${CLASS_ROOT}--${size}`]: size,
        },
        className,
    );

    let icon = <span>{'?'}</span>;
    switch (value.toLowerCase()) {
        case 'ok':
        case 'normal':
            icon = <StatusGood {...props} className={classes} />;
            break;
        case 'warning':
            icon = <StatusWarning {...props} className={classes} />;
            break;
        case 'critical':
            icon = <StatusCritical {...props} className={classes} />;
            break;
        case 'disabled':
            icon = <StatusDisabled {...props} className={classes} />;
            break;
        case 'unknown':
            icon = <StatusUnknown {...props} className={classes} />;
            break;
        default:
            icon = null;
    }
    return icon;
}

StatusIcon.propTypes = {
    a11yTitle: PropTypes.string,
    size: PropTypes.oneOf(['small', 'medium', 'large']),
    value: PropTypes.oneOf(['critical', 'warning', 'ok', 'unknown',
        'disabled', 'label',
        'Critical', 'Warning',
        'OK', 'Unknown',
        'Disabled',
        'Label', 'blank',
    ]),
};

StatusIcon.defaultProps = {
    value: 'unknown',
};
