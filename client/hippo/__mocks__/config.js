/* global jest */
window.localStorage = {
    getItem() {
        return '{}';
    },
};

const Config = jest.genMockFromModule('../models/config');
const { default: DefaultConfig } = Config;
const config =  new DefaultConfig();

Object.defineProperty(config, 'api_path', {
    value: '/api',
});

export default config;
