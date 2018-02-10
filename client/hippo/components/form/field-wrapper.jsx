import React from 'react'; // eslint-disable-line no-unused-vars
import { Box, Text } from 'grommet';
import { includes } from 'lodash';
import cn from 'classnames';
import color from 'grommet/utils/colors';
import styled from 'styled-components';
import { Cell } from '../../components/grid';
import { titleize } from '../../lib/util';
import { colorWrapperStyles } from './fields/color';

const STYLES = {
    color: colorWrapperStyles,
};

const UNDERLINED_TYPES = ['text', 'textarea', 'number', 'password', 'date', 'email'];

const controlStyle = () => (`
padding-right: 3px;
input {
  padding-right: 0;
}
`);

const ControlsWrapper = styled.div`
display: flex;
align-items: flex-end;
${props => props.control && controlStyle(props)}
`;

const borderBottom = props => (`
border-bottom: solid ${props.theme.global.borderSize.small} ${color.colorForName('light-2', props.theme)};
`);

const StyledWrapper = Cell.withComponent('label').extend`
padding: 3px;
display: flex;
flex-direction: column;
justify-content: space-between;
${props => includes(UNDERLINED_TYPES, props.type) && borderBottom(props)}
&:focus-within {
  border-bottom-color: ${props => color.colorForName('light-4', props.theme)};
  span {
    font-weight: 500;
  }
}
input[type="checkbox"] {
  margin-left: ${props => props.theme.global.edgeSize.small};
}
${props => STYLES[props.type] && STYLES[props.type](props)}

`;

export { StyledWrapper };

export default function FieldWrapper({
    control, label: labelVal, name, help, error, children, className, ...cellProps
}) {
    let header;
    const label = (!labelVal && labelVal !== false) ? titleize(name) : labelVal;
    if (label || help || error) {
        header = (
            <Box
                wrap
                direction='row'
                justify='between'
                pad={{ horizontal: 'small', top: 'xsmall' }}
            >
                <Text>{label}</Text>
                <Text truncate color={error ? 'status-critical' : 'dark-5'}>{error || help}</Text>
            </Box>
        );
    }
    return (
        <StyledWrapper {...cellProps} className={cn('form-field-wrapper', className)}>
            {header}
            <ControlsWrapper control={control}>{children}</ControlsWrapper>
        </StyledWrapper>
    );
}
