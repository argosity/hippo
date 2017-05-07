/* global jest */

/**
 * Copyright 2004-present Facebook. All Rights Reserved.
 *
 * Implements basic mock for the fetch interface use `whatwg-fetch` polyfill.
 *
 * See https://fetch.spec.whatwg.org/
 */


function ResponseWrapper(body) {
    const response = {};
    response.body = ('object' === typeof body) ? JSON.stringify(body) : body;
    const actualClone = response.clone;
    response.clone = () => {
        const clone = actualClone.call(response);
        const [body1, body2] = body.tee();
        response.body = body1;
        clone.body = body2;
        return clone;
    };
    response.json = () => (response.body ? JSON.parse(response.body) : {});
    return response;
}

const fetch = jest.fn();

fetch.Response = ResponseWrapper;

fetch.mockResponse = (body, init) => {
    fetch.mockImplementation(
    () => Promise.resolve(new ResponseWrapper(body, init)),
  );
};

fetch.mockResponseOnce = (body, init) => {
    fetch.mockImplementationOnce(
    () => Promise.resolve(new ResponseWrapper(body, init)),
  );
};

fetch.mockResponses = (...responses) => {
    responses.forEach(([body, init]) => {
        fetch.mockImplementationOnce(
      () => Promise.resolve(new ResponseWrapper(body, init)),
    );
    });
};

// Default mock is just a empty string.
fetch.mockResponse('');

module.exports = fetch;
