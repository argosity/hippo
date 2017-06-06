import { AsyncStorage } from 'react-native';
import Config from './models/config';

const ConfigInstance = Config.create({
    storage: AsyncStorage,
});

export default ConfigInstance;
