import { shallow, mount } from 'enzyme';
import { useStrict } from 'mobx';
import { fetch } from './mocks';

import 'jest-enzyme';
// jest.mock('flexboxgrid', () => {
//     return {};
// });

//useStrict(true);

global.shallow = shallow;
global.mount   = mount;
global.fetch   = fetch;

jasmine.addMatchers({

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
