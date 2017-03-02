const { shallow, mount } = require('enzyme');
const { fetch } = require('./mocks');

global.shallow = shallow;
global.mount   = mount;
global.fetch   = fetch;
global.React   = require('React');

jest.addMatchers({

    toHaveRendered() {
        return {
            compare: (wrapper, selector) => {
                const matchCount = wrapper.find(selector).length;
                const result = { pass: 1 === matchCount };
                if (result.pass) {
                    result.message = `${selector} was found`;
                } else {
                    result.message = `Expected wrapper to contain '${selector}' only once, but it was found ${matchCount} times`;
                }
                return result;
            },
        };
    },

});
