// Code included here will be ran to setup your specs.
// it's a usefull spot to setup globals or custom matchers
require('hippo/testing');
const matchers = require('hippo/testing/matchers');
const { shallow, mount } = require('enzyme');
const log = require('loglevel');

log.setLevel(log.levels.WARN);

global.expect.extend(matchers);

global.shallow = shallow;
global.mount   = mount;
global.fetch   = require('hippo/testing/mocks/fetch');
global.React   = require('react');
