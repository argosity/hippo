import { configure, shallow, mount } from 'enzyme';
import { React } from 'hippo/testing';
import Adapter from 'enzyme-adapter-react-16';

configure({ adapter: new Adapter() });

global.shallow = shallow;
global.mount   = mount;
global.React   = React;

// eslint-disable-next-line import/no-dynamic-require
global.fixture = file => require(`../fixtures/sm/${file}.yml`); // eslint-disable-line global-require

// jsdom fix https://github.com/tmpvar/jsdom/issues/1695
global.HTMLElement.prototype.scrollIntoView = function() {};

global.requestAnimationFrame = function(callback) {
    setTimeout(callback, 0);
};
