window.localStorage = {

    getItem() {
        return '{}';
    },

};

const config = jest.genMockFromModule('lanes/config');

config.bootstrapUserData = jest.fn();
config.reset = jest.fn();
Object.defineProperty(config, 'api_path', {
    value: '/api'
});

export default config;
