/* global jest */

const MockedRequestAssets = jest.fn((...urls) =>
    new Promise(resolve => resolve(urls)),
);
export default MockedRequestAssets;
