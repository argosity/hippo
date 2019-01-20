import { Grid, Cell } from 'styled-css-grid';
import styled, { css } from 'styled-components';
import media from './grid/media';

const middle = css`
  flex-flow: row;
  align-items: center;
`;

const gap = css`
  > *:not(:first-child) {
    margin-left: ${props => props.theme.global.edgeSize[props.gap]};
  }
`;

const StyledCell = styled(Cell)`
  ${props => props.middle && middle}
  ${props => props.gap && gap}
  ${props => props.desktop && media.desktop`grid-column-end: span ${props.desktop};`}
  ${props => props.tablet && media.tablet`grid-column-end: span ${props.tablet};`}
  ${props => props.phone && media.phone`grid-column-end: span ${props.phone};`}
`;

export { StyledCell as Cell, Grid };
