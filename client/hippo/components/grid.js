import { Grid, Cell as StyledCell } from 'styled-css-grid';
import media from './grid/media';

const Cell = StyledCell.extend`
${props => props.desktop && media.desktop`grid-column-end: span ${props.desktop};`}
${props => props.tablet && media.tablet`grid-column-end: span ${props.tablet};`}
${props => props.phone && media.phone`grid-column-end: span ${props.phone};`}
`;

export { Cell, Grid };
