import React from 'react'; // eslint-disable-line no-unused-vars
import cn from 'classnames';
import './spinning.scss';

const CLASS_ROOT = 'icon-spinning';

export default function Spinning(props) {
    const {
        className, small, size, responsive, ...otherProps
    } = props;

    const sizeOverride = small ? 'small' : size;

    const classes = cn(
        CLASS_ROOT,
        {
            [`${CLASS_ROOT}--${sizeOverride}`]: sizeOverride,
            [`${CLASS_ROOT}--responsive`]: responsive,
        },
        className,
    );

    return (
        <svg
            {...otherProps}
            className={classes} viewBox='0 0 48 48' version='1.1'
            role='img'
        >
            <circle
                cx="24" cy="24" r="21"
                stroke="#979797" strokeWidth="6" fill="none"
            />
        </svg>
    );
}
