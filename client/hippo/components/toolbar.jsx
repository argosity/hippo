import React from 'react'; // eslint-disable-line no-unused-vars
import Box from 'grommet/components/Box';
//import StyledBox from 'hippo/components/Box/StyledBox';
import cn from 'classnames';

export SaveButton from './save-button';
import styled from 'styled-components';

const TB = styled(Box)`
> *:not(:first-child) {
  margin-left: ${props => props.theme.global.edgeSize.small}
};
`;

export function Toolbar({ children, className, ...props }) {
    return (
        <TB
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
        </TB>
    );
}

Toolbar.expand = styled.div`
flex: 1;
`;
