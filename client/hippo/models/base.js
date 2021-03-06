import PropTypes from 'prop-types';
import { findModel } from 'mobx-decorated-models';
import { readonly } from 'core-decorators';
import invariant from 'invariant';
import {
    isEmpty, isNil, find, pick,
} from 'lodash';
import { action, observable, computed } from 'mobx';
import ModelSyncAdapter from './model-sync';
import lazyGetter from '../lib/lazy-getter';
import Config from '../config';
import { identifier } from './decorators';
import { classify } from '../lib/util';
import ModelCollection from './collection';

export {
    identifiedBy, belongsTo, hasMany, field, session,
} from 'mobx-decorated-models';
export {
    action, autorun,
} from 'mobx';
export { identifier };


export {
    observable, computed,
};

export class BaseModel {

    static get propType() {
        return PropTypes.instanceOf(this);
    }

    static findDerived(name) {
        return findModel(name);
    }

    static get assignableKeys() {
        return Array.from(this.$mxdm.properties.keys());
    }

    @lazyGetter sync = new ModelSyncAdapter({ model: this })

    static get propertyOptions() {
        const options = {};
        // return pick(this.$mxdm.properties, 'options');
        this.$mxdm.properties.forEach((val, name) => { options[name] = val.options; });
        return options;
    }

    static get syncUrl() {
        invariant(this.identifiedBy, 'must have an identifiedBy property in order to calulate syncUrl');
        return `${Config.api_path}/${this.identifiedBy}`;
    }

    static get serverModel() {
        return classify(this.identifiedBy);
    }

    static get identifierFieldName() {
        const field = find(Array.from(this.$mxdm.properties.values()), { type: 'identifier' });
        invariant(field, 'identifierFieldName called on a model that has not designated one with `@identifier`');
        return field.name;
    }

    static get Collection() {
        if (!this.$collection) { this.$collection = new ModelCollection(this); }
        return this.$collection;
    }

    constructor(attrs) {
        if (!isEmpty(attrs)) {
            this.set(attrs);
        }
    }

    @readonly isModel = true;

    //    @observable syncInProgress = false;
    //    @observable lastServerMessage = '';
    //    @observable errors = {};

    @computed get isValid() {
        return isNil(this.errors) || isEmpty(this.errors);
    }

    @computed get isNew() {
        return isNil(this.identifierFieldValue);
    }

    @computed get identifierFieldValue() {
        return this[this.constructor.identifierFieldName];
    }

    // @computed get syncUrl() {
    //     const path = this.constructor.syncUrl;
    //     return this.isNew ? path : `${path}/${this.identifierFieldValue}`;
    // }

    set(attrs = {}) {
        Object.assign(this, pick(attrs, this.constructor.assignableKeys));
        return this;
    }

    @action reset() {
        this.constructor.assignableKeys.forEach((k) => { this[k] = null; });
    }

    // fetch(options = {}) {
    //     invariant((!this.isNew || options.query),
    //         'Unable to fetch record without it’s identifier being set or a query');
    //     const fetchOptions = extend(options, { limit: 1, method: 'GET' });
    //     if (!fetchOptions.query) {
    //         fetchOptions.query = { [`${this.constructor.identifierFieldName}`]: this.identifierFieldValue };
    //     }
    //     return Sync.forModel(this, fetchOptions);
    // }

    // save(options = {}) {
    //     return Sync.forModel(this, options);
    // }
    //
    // destroy(options = {}) {
    //     return Sync.forModel(this, extend(options, { action: 'destroy' }));
    // }
    //

}

export default BaseModel;
