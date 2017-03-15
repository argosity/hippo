/* global jest */

let nextResponse = {
    success: true,
    data: {},
    message: 'success',
};

const perform = jest.fn(() => Promise.resolve(nextResponse));

const forModel = jest.fn(() => Promise.resolve(nextResponse));

function setResponseData(response) {
    nextResponse = response;
}

export default {
    forModel,
    perform,
    setResponseData,
};
