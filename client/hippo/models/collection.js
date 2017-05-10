import { observable } from 'mobx';
import invariant from 'invariant';
import { extend, isArray, isObject } from 'lodash';
import { createCollection } from 'mobx-decorated-models';

import Sync from './sync';

function extendAry(modelClass, models = [], options = {}) {
    invariant(isArray(models), 'models must be an array');
    const ary = createCollection(extend({ model: modelClass }, options));

    if (models.length) {
        ary.replace(models);
    }

    ary.$map = observable.map({
        lastServerMessage: '',
        syncInProgress:    '',
        errors:            {},
    });
    ary.$map.keys().forEach((prop) => {
        Object.defineProperty(ary, prop, {
            get() { return this.$map.get(prop); },
            set(val) { return this.$map.set(prop, val); },
        });
    });
    Object.defineProperties(ary, {
        syncUrl: {
            get() { return modelClass.syncUrl; },
        },
        syncData: {
            set(rows) {
                this.replace(rows);
            },
        },
    });
    ary.fetch = function(fetchOptions = {}) {
        return Sync.forCollection(this, fetchOptions);
    };
    if (options.fetch) {
        ary.fetch(isObject(options.fetch) ? options.fetch : {});
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
