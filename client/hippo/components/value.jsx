import React from 'react'; // eslint-disable-line no-unused-vars
import PropTypes from 'prop-types';
import classnames from 'classnames';

const CLASS_ROOT = 'hip-value';
const COLOR_INDEX = 1;

export default function Value({
    active, align, className, colorIndex, icon, label, responsive,
    size, onClick, trendIcon, units, value, reverse, ...otherProps
}) {
    const classes = classnames(
        CLASS_ROOT,
        {
            [`${CLASS_ROOT}--${size}`]: size,
            [`${CLASS_ROOT}--align-${align}`]: align,
            [`${COLOR_INDEX}-${colorIndex}`]: colorIndex,
            [`${CLASS_ROOT}--responsive`]: responsive,
            [`${CLASS_ROOT}--interactive`]: onClick,
            [`${CLASS_ROOT}--active`]: active,
        },
        className,
    );

    let unitsSpan;
    if (units) {
        unitsSpan = (
            <span className={`${CLASS_ROOT}__units`}>
                {units}
            </span>
        );
    }

    let labelSpan;
    if (label) {
        labelSpan = (
            <span className={`${CLASS_ROOT}__label`}>
                {label}
            </span>
        );
    }

    let contentNode;
    if (reverse) {
        contentNode = (
            <div>
                <span className={`${CLASS_ROOT}__value`}>
                    {value}
                </span>
                {unitsSpan}
                {icon}
            </div>
        );
    } else {
        contentNode = (
            <div>
                {icon}
                <span className={`${CLASS_ROOT}__value`}>
                    {value}
                </span>
                {unitsSpan}
            </div>
        );
    }

    return (
        <div
            {...otherProps}
            className={classes}
        >
            <div className={`${CLASS_ROOT}__annotated`}>
                {contentNode}
                {trendIcon}
            </div>
            {labelSpan}
        </div>
    );
}

Value.propTypes = {
    active: PropTypes.bool,
    align: PropTypes.oneOf(['start', 'center', 'end']),
    announce: PropTypes.bool,
    colorIndex: PropTypes.string,
    icon: PropTypes.node,
    label: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
    onClick: PropTypes.func,
    responsive: PropTypes.bool,
    size: PropTypes.oneOf(['xsmall', 'small', 'medium', 'large', 'xlarge']),
    trendIcon: PropTypes.node,
    reverse: PropTypes.bool,
    value: PropTypes.oneOfType([PropTypes.number, PropTypes.string, PropTypes.node]),
    units: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
};

Value.defaultProps = {
    align: 'center',
    announce: false,
};
