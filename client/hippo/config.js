import Config from './models/config';

const ConfigInstance = Config.create({
    storage: window.localStorage,
    jsonify: true,
});

export default ConfigInstance;
