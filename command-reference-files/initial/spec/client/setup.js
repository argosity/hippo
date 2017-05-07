// Code included here will be ran to setup your specs.
// it's a usefull spot to setup globals or custom matchers
import matchers from 'hippo/testing/matchers';
import { shallow, mount } from 'enzyme';
import { fetch } from 'hippo/testing/mocks/fetch';
import React from 'react';
import 'hippo/testing';

global.expect.extend(matchers);

global.shallow = shallow;
global.mount   = mount;
global.fetch   = fetch;
global.React   = React;

// eslint-disable-next-line import/no-dynamic-require
global.fixture = file => require(`../fixtures/appy-app/${file}.yml`); // eslint-disable-line global-require
