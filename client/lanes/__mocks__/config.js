window.localStorage = {

    getItem() {
        return '{}';
    },

};

const config = jest.genMockFromModule('lanes/config');

module.exports = config;
