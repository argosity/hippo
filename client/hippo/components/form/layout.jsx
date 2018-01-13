import React from 'react';
import PropTypes from 'prop-types';
import styled from 'styled-components';
import { Grid } from 'styled-css-grid';

const Layout = Grid.extend.attrs({
    columns: props => props.columns || 'repeat(auto-fill, minmax(280px, 1fr))',
    flow: props => props.flow || 'row dense',
})`
flex: 1;
overflow: auto;
grid-area: body;
align-content: flex-start;
-webkit-overflow-scrolling: touch;
padding: ${props => props.theme.global.edgeSize.small};
grid-auto-rows: minmax(${props => props.rowHeight || 80}px, auto);
`;

export default Layout;
