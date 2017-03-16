/* global jest */

let nextResponse = {
    success: true,
    data: {},
    message: 'success',
};

// make our own "Promise" instead of Promise.resolve
// since that has a hidden timeout and we want to call inline
const perform = jest.fn(() => ({
    then(cb) { return cb(nextResponse); },
}));

const forModel = jest.fn(() => ({
    then(cb) { return cb(nextResponse); },
}));


function setResponseData(response) {
    nextResponse = response;
}

export default {
    forModel,
    perform,
    setResponseData,
};
