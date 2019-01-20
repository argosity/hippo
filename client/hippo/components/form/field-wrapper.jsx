import React from 'react'; // eslint-disable-line no-unused-vars
import { Box, Text } from 'grommet';
import { includes, isString } from 'lodash';
import cn from 'classnames';
import { normalizeColor } from 'grommet/utils/colors';
import styled, { css } from 'styled-components';
import { Cell } from '../grid';
import { titleize } from '../../lib/util';

const UNDERLINED_TYPES = ['text', 'textarea', 'number', 'password', 'date', 'email'];

const isUnderlined = props => Boolean(props.underlined || includes(UNDERLINED_TYPES, props.type));

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

const borderBottom = css`
  background: white no-repeat;
  background-image: linear-gradient(to bottom,
    ${props => normalizeColor('focus', props.theme)},
    ${props => normalizeColor('focus', props.theme)}
  ), linear-gradient(to bottom,
    ${props => normalizeColor('focus', props.theme)},
    ${props => normalizeColor('focus', props.theme)}
  );
  background-size: 0 2px, 100% 1px;
  background-position: 50% 100%, 50% 100%;
  transition: background-size 0.3s cubic-bezier(0.64, 0.09, 0.08, 1);
`;

const StyledWrapper = styled(Cell)`
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  ${props => isUnderlined(props) && borderBottom}
  &.focused,
  &:focus-within {
    background-size: 100% 2px, 100% 1px;
    outline: none;
    span {
    font-weight: 500;
  }
}
input[type="checkbox"] {
  margin-left: ${props => props.theme.global.edgeSize.small};
}
${props => props.styles}
`;

export { StyledWrapper };

export default function FieldWrapper({
    control, label: labelVal, name, help, error, children, className,
    desktop, tablet, phone, cellWidth = 3, type, focused,
    ...cellProps
}) {
    const label = (!labelVal && labelVal !== false) ? titleize(name) : labelVal;
    const sizeProps = {
        desktop: (desktop || cellWidth),
        tablet: (tablet || cellWidth),
        phone: (phone || cellWidth),
    };

    let header;
    if (label || help || error) {
        header = (
            <Box
                wrap
                direction="row"
                className="labels"
                justify="between"
                pad={{ horizontal: 'small', top: 'xsmall' }}
            >
                <Text>{label}</Text>
                <Text truncate color={error ? 'status-critical' : 'dark-5'}>
                    {error || help}
                </Text>
            </Box>
        );
    }

    return (
        <StyledWrapper
            {...cellProps}
            {...sizeProps}
            type={isString(type) ? type : ''}
            className={cn('form-field-wrapper', className, { focused })}
        >
            {header}
            <ControlsWrapper control={control}>{children}</ControlsWrapper>
        </StyledWrapper>
    );
}
