import React from 'react'; // eslint-disable-line no-unused-vars
import Box from 'grommet/components/Box';
import cn from 'classnames';

export SaveButton from './save-button';

export function Toolbar({ children, className, ...props }) {
    return (
        <Box
            gridArea="header"
            direction="row"
            align="center"
            background="light-3"
            margin="none"
            className={cn('hippo-toolbar', className)}
            pad={{ horizontal: 'small', vertical: 'small', between: 'small' }}
            {...props}
        >
            {children}
        </Box>
    );
}
