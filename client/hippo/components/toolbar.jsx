import React from 'react'; // eslint-disable-line no-unused-vars
import { Box } from 'grommet';
import cn from 'classnames';
import { base as grommetTheme } from 'grommet/themes';
import styled from 'styled-components';

export SaveButton from './save-button';

const TB = styled(Box)`
a,
button {
  padding: ${props => props.theme.global.edgeSize.small};
  > * {
    padding: 0;
  }
};
.query-builder {
  flex: 1;
}
`;

export function Toolbar({ children, className, ...props }) {
    return (
        <TB
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
        </TB>
    );
}

Toolbar.defaultProps = {
    theme: grommetTheme,
};

Toolbar.expand = styled.div`
flex: 1;
`;
