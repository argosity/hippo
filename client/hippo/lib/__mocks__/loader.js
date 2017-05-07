/* global jest */

const loadJS = jest.fn((src, cb) => {
    cb(src, {});
});

const loadCSS = jest.fn((src, cb) => {
    cb(src, {});
});

export { loadJS, loadCSS };
