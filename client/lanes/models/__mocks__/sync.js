/* global jest */


let nextResponse = {
    success: true,
    data: {},
    message: 'success',
};
const perform = jest.fn((urlPrefix, defaultOptions = {}) => {
    return Promise.resolve(nextResponse);
});

const forModel = jest.fn((model, options = {}) => {
    return Promise.resolve( nextResponse );
});

function setResponseData(response){
    nextResponse = response;
}

export default {
    forModel,
    perform,
    setResponseData
};
