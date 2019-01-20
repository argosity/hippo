import React from 'react'; // eslint-disable-line no-unused-vars
import { Grid } from 'styled-css-grid';
import styled from 'styled-components';

const Layout = styled(Grid).attrs({
    columns: props => props.columns || 'repeat(auto-fill, minmax(120px, 1fr))',
    flow: props => props.flow || 'row dense',
})`
flex: 1;
align-content: flex-start;
-webkit-overflow-scrolling: touch;
padding: ${props => props.theme.global.edgeSize.small};
grid-auto-rows: minmax(${props => props.rowHeight || 80}px, auto);
> * {
min-height: 85px;
}
`;

const StyledFormLayout = styled.div`
grid-area: body;
overflow: auto;
flex: 1;
`;


const FormLayout = ({ children, ...props }) => (
    <StyledFormLayout>
        <Layout {...props}>
            {children}
        </Layout>
    </StyledFormLayout>

);

export default FormLayout;
