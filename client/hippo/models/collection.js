import invariant from 'invariant';
import { extend, isArray, isObject } from 'lodash';
import { createCollection } from 'mobx-decorated-models';
import CollectionSyncAdapter from './collection-sync';

function extendAry(modelClass, models = [], options = {}) {
    invariant(isArray(models), 'models must be an array');
    const ary = createCollection(extend({ model: modelClass }, options));

    if (models.length) {
        ary.replace(models);
    }

    Object.defineProperties(ary, {
        sync: {
            configurable: true,
            enumerable: false,
            get() {
                const sync = new CollectionSyncAdapter({
                    syncUrl: modelClass.syncUrl,
                    array: ary,
                });
                Object.defineProperty(ary, 'sync', {
                    configurable: true,
                    enumerable: false,
                    writable: false,
                    value: sync,
                });
                return sync;
            },
        },
    });
    if (options.fetch) {
        ary.sync.fetch(isObject(options.fetch) ? options.fetch : {});
    }

    return ary;
}

export default class ModelCollection {

    constructor(model) {
        this.$model = model;
        this.$collection = extendAry(model, [], {}, this);
        return this;
    }

    create(models = [], options = {}) {
        return extendAry(this.$model, models, options, this);
    }

}
