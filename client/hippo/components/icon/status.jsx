import React, { Component } from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';
import OK from './status/OK';
import CriticalStatus from './status/CriticalStatus';
import Warning from './status/Warning';
import Disabled from './status/Disabled';
import Unknown from './status/Unknown';
import Blank from './status/Blank';
import Label from './status/Label';
import CSSClassnames from '../../utils/CSSClassnames';

const CLASS_ROOT = 'status-icon';

export default function StatusIcon({ className, size, value, ...props }) {

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
            icon = <OK {...props} className={classes} />;
            break;
        case 'warning':
            icon = <Warning {...props} className={classes} />;
            break;
        case 'critical':
            icon = <CriticalStatus {...props} className={classes} />;
            break;
        case 'disabled':
            icon = <Disabled {...props} className={classes} />;
            break;
        case 'unknown':
            icon = <Unknown {...props} className={classes} />;
            break;
        case 'blank':
            icon = <Blank {...props} className={classes} />;
            break;
        case 'label':
            icon = <Label {...props} className={classes} />;
            break;
        default:
            icon = null;
    }
    return icon;
}

Status.propTypes = {
    a11yTitle: PropTypes.string,
    size: PropTypes.oneOf(['small', 'medium', 'large']),
    value: PropTypes.oneOf(['critical', 'warning', 'ok', 'unknown',
        'disabled', 'label',
        'Critical', 'Warning', 'OK', 'Unknown', 'Disabled', 'Label', 'blank'])
};

Status.defaultProps = {
    value: 'unknown'
};
