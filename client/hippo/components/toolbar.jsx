import React from 'react'; // eslint-disable-line no-unused-vars
import { Box } from 'grommet';
import cn from 'classnames';
import baseTheme from 'grommet/themes/vanilla';
import styled from 'styled-components';

export SaveButton from './save-button';

export function Toolbar({ children, className, ...props }) {
    return (
        <Box
            fill="horizontal"
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

Toolbar.expand = styled.div`
flex: 1;
`;
