import React from 'react'; // eslint-disable-line no-unused-vars
import Header from 'grommet/components/Header';
import cn from 'classnames';

export SaveButton from './save-button';

export function Toolbar({ children, className, ...props }) {
    return (
        <Header
            align="center"
            fixed colorIndex="light-2"
            className={cn('hippo-toolbar', className)}
            pad={{ horizontal: 'small', vertical: 'small', between: 'small' }}
            {...props}
        >
            {children}
        </Header>
    );
}
