import { css } from 'styled-components';
import { Grid, Cell as StyledCell } from 'styled-css-grid';

const SIZES = {
    desktop: 992,
    tablet: 768,
    phone: 376,
};

const SIZE_KEYS = Object.keys(SIZES);

// Iterate through the sizes and create a media template
const media = SIZE_KEYS.reduce((acc, label) => {
    acc[label] = (...args) => css`

    @media (min-width: ${SIZES[label]}px) {
      ${css(...args)}
    }
  `;
    return acc;
}, {});

const Cell = StyledCell.extend`
${props => props.desktop && media.desktop`grid-column-end: span ${props.desktop};`}
${props => props.tablet && media.tablet`grid-column-end: span ${props.tablet};`}
${props => props.phone && media.phone`grid-column-end: span ${props.phone};`}
`;

export { Cell, Grid };
