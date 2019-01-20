/* global jest */

let nextResponse = {
    success: true,
    data: {},
    message: 'success',
};

const sync = jest.fn(() => Promise.resolve(nextResponse));

sync.setResponseData = (response) => {
    nextResponse = response;
};

export default sync;
