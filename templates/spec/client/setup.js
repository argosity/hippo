// Code included here will be ran to setup your specs.
// it's a usefull spot to setup globals or custom matchers
import matchers from 'lanes/testing/matchers';
import { shallow, mount } from 'enzyme';
import { fetch } from 'lanes/testing/mocks/fetch';
import React from 'react';
import 'lanes/testing';

global.expect.extend(matchers);

global.shallow = shallow;
global.mount   = mount;
global.fetch   = fetch;
global.React   = React;

// eslint-disable-next-line import/no-dynamic-require
global.fixture = file => require(`../fixtures/<%= identifier %>/${file}.yml`); // eslint-disable-line global-require
