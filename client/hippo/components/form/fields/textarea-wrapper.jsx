import React from 'react';
import { observer } from 'mobx-react';
import styled from 'styled-components';
import { TextArea } from 'grommet';

// console.log(TextArea)
// debugger

const StyledArea = styled(TextArea)`
flex: 1;
height: 100%;
`;

@observer
export default class TextAreaWrapper extends React.Component {

    render() {
        return (
            <StyledArea {...this.props} />
        );
    }

}
