// Code included here will be ran to setup your specs.
// it's a usefull spot to setup globals or custom matchers
const matchers = require('lanes/jest/matchers');
const { shallow, mount } = require('enzyme');

global.expect.extend(matchers);

global.shallow = shallow;
global.mount   = mount;
global.fetch   = require('lanes/jest/mocks/fetch');
global.React   = require('React');
