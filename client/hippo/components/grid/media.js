import { css } from 'styled-components';

const SIZES = {
    desktop: 992,
    tablet: 768,
    phone: 300,
};

const SIZE_KEYS = Object.keys(SIZES);

// Iterate through the sizes and create a media template
const media = SIZE_KEYS.reduce((acc, label) => {
    acc[label] = (...args) => css`
    @media (min-width: ${SIZES[label]}px) {
      ${css(...args)}
    }`;
    return acc;
}, {});

export default media;
