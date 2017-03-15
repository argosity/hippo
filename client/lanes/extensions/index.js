import { invoke, each } from 'lodash';
import { observable } from 'mobx';

export default {

    instances: observable.map(),

    @observable controlling_id: 'lanes',

    register(Klass) {
        const instance = new Klass();
        this.instances.set(instance.identifier, instance);
        return invoke(instance, 'onRegistered');
    },

    invoke(method, arg) {
        each(this.instances.values(), instance => invoke(instance, method, arg));
    },

    fireOnInitialized(viewport) {
        this.invoke('onInitialized', viewport);
    },

    fireOnAvailable(viewport) {
        this.invoke('onAvailble', viewport);
    },

    getViews() {
        return Promise.all(this.invoke('getView'));
    },

    get controlling() {
        return this.get(this.controlling_id);
    },

    get(identifier) {
        return this.instances.get(identifier);
    },

    setBootstrapData(bootstrapData) {
        this.controlling_id = bootstrapData.controlling_extension;
        this.instances.forEach((instance, key) => {
            invoke(instance, 'setBootstrapData', bootstrapData[key]);
        });
    },

};

function __guardMethod__(obj, methodName, transform) {
    if ('undefined' !== typeof obj && null !== obj && 'function' === typeof obj[methodName]) {
        return transform(obj, methodName);
    }
    return undefined;
}
