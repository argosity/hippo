import React from 'react'; // eslint-disable-line no-unused-vars
import PropTypes from 'prop-types';
import classnames from 'classnames';
import styled, { css } from 'styled-components';

const CLASS_ROOT = 'hip-value';
const COLOR_INDEX = 1;


const sizeStyle = (props, sizeType) => {
    // size is a combination of the level and size properties
    const size = props.size || sizeType || 'medium';
    const data = props.theme.text[size];
    return css`
    font-size: ${data.size};
    line-height: ${data.height};
  `;
};

const Units = styled.span`
  ${props => sizeStyle(props)}
`;

const Label = styled.span`
font-size: 1.1875rem;
line-height: 1.26316;
display: inline-block;
`;

const Content = styled.div`
display: flex;
flex-direction: ${props => (props.reversed ? 'row-reverse' : 'row')};
`;

const InnerValue = styled.span`
font-weight: 500;
font-size: 2.25rem;
line-height: 1.33333;
`;

const Annotated = styled.div`
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: center;
  align-items: center;
  ${props => sizeStyle(props)}
`;

const StyledValue = styled.div`
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: center;
  align-items: center;
`;

export default function Value({
    active, align, className, colorIndex, icon, label, responsive,
    size, onClick, trendIcon, units, value, ...otherProps
}) {
    const classes = classnames(
        CLASS_ROOT,
        {
            [`${CLASS_ROOT}--${size}`]: size,
            [`${CLASS_ROOT}--align-${align}`]: align,
            [`${COLOR_INDEX}-${colorIndex}`]: colorIndex,
            [`${CLASS_ROOT}--responsive`]: responsive,
            [`${CLASS_ROOT}--interactive`]: onClick,
            [`${CLASS_ROOT}--active`]: active,
        },
        className,
    );

    const unitsSpan = units && <Units>{units}</Units>;
    const labelSpan = label && <Label>{label}</Label>;
    const contentNode = (
        <Content reversed>
            <InnerValue>{value}</InnerValue>
            {unitsSpan}
            {icon}
        </Content>
    );

    return (
        <StyledValue
            {...otherProps}
            className={classes}
        >
            <Annotated>
                {contentNode}
                {trendIcon}
            </Annotated>
            {labelSpan}
        </StyledValue>
    );
}

Value.propTypes = {
    active: PropTypes.bool,
    align: PropTypes.oneOf(['start', 'center', 'end']),
    announce: PropTypes.bool,
    colorIndex: PropTypes.string,
    icon: PropTypes.node,
    label: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
    onClick: PropTypes.func,
    responsive: PropTypes.bool,
    size: PropTypes.oneOf(['xsmall', 'small', 'medium', 'large', 'xlarge']),
    trendIcon: PropTypes.node,
    reverse: PropTypes.bool,
    value: PropTypes.oneOfType([PropTypes.number, PropTypes.string, PropTypes.node]),
    units: PropTypes.oneOfType([PropTypes.string, PropTypes.node]),
};

Value.defaultProps = {
    align: 'center',
    announce: false,
};
