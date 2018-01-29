import 'jest-styled-components';
import matchers from 'hippo/testing/matchers';
import fetch from 'hippo/testing/mocks/fetch';

global.fetch = fetch;
global.expect.extend(matchers);
