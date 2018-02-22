import React from 'react'; // eslint-disable-line no-unused-vars
import Box from 'grommet/components/Box';
import cn from 'classnames';
import baseTheme from 'grommet/themes/vanilla';

export SaveButton from './save-button';

export function Toolbar({ children, className, ...props }) {
    return (
        <Box
            flex
            gridArea="header"
            direction="row"
            align="center"
            background="light-3"
            margin="none"
            gap="small"
            className={cn('hippo-toolbar', className)}
            pad={{ horizontal: 'small', vertical: 'small', between: 'small' }}
            {...props}
        >
            {children}
        </Box>
    );
}

Toolbar.defaultProps = {
    theme: baseTheme,
};
