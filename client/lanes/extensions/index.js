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
        return this.get( this.controlling_id );
    },

    get(identifier) {
        return this.instances.get(identifier);
    },

    setBootstrapData(bootstrapData) {
        this.controlling_id = bootstrapData.controlling_extension;
        this.instances.forEach((instance, key) => {
            invoke(instance, 'setBootstrapData', bootstrapData[key]);
        });
        //     invoke(instance, method, arg));
        // return (() => {
        //     const result = [];
        //     for (var identifier in this.instances) {
        //         const instance = this.instances[identifier];
        //         result.push(__guardMethod__(instance, 'setBootstrapData', o => o.setBootstrapData(bootstrap_data[identifier])));
        //     }
        //     return result;
        // })();
    }

    // makeNamespace(identifier) {
    //     return ['Models', 'Controllers', 'Screens', 'Components'].map((ns) =>
    //         Lanes.namespace(`${identifier}.${ns}.Mixins`));
    // },


    // routes() {

    //     return _.flatten(_.map(this.instances, (instance, id) => __guardMethod__(instance, 'getRoutes', o => o.getRoutes()))
    //     );
    // },

};

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}
