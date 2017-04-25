/* global jest */

let nextResponse = {
    success: true,
    data: {},
    message: 'success',
};

export default {
    forModel: jest.fn(() => Promise.resolve(nextResponse)),
    forCollection: jest.fn(() => Promise.resolve(nextResponse)),
    perform: jest.fn(() => Promise.resolve(nextResponse)),

    setResponseData(response) {
        nextResponse = response;
    },
};
