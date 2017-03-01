import { observable, action, computed, extendShallowObservable, intercept, observer } from 'mobx';
import invariant from 'invariant';
import { extend, each, isArray } from 'lodash';
import { buildCollection } from 'mobx-decorated-models';

import Sync from './sync';

function extendAry(modelClass, models = [], options) {
    invariant(isArray(models), 'models must be an array');
    const ary = buildCollection(extend({ model: modelClass }, options));

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
    Object.defineProperty(ary, 'syncUrl', {
        get() { return modelClass.syncUrl; },
    });
    ary.fetch = function(fetchOptions = {}) {
        return Sync.forCollection(this, fetchOptions).then((json) => {
            each(json.data, rec => ary.push(rec));
            return ary;
        });
    };
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
