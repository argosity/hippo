import React from 'react'; // eslint-disable-line no-unused-vars
import FAIcon from 'react-fontawesome';
import cn from 'classnames';

const Icon = (props) => {
    const { className, ...otherProps } = props;
    return (
        <FAIcon className={cn('icon', className)} {...otherProps} />
    );
};

export default Icon;
