import PropTypes from 'prop-types';
import {
    findModel,
} from 'mobx-decorated-models';
import invariant from 'invariant';
import {
    isEmpty, isNil, find, extend, assign, pick, map,
} from 'lodash';

import { action, observable, computed } from 'mobx';

import pluralize from 'pluralize';

import Sync from './sync';
import Config from '../config';
import { toSentence, humanize } from '../lib/util';
import ModelCollection from './collection';

export {
    identifiedBy, belongsTo, hasMany,
} from 'mobx-decorated-models';
export {
    action, autorun,
} from 'mobx';
export {
    field, session, identifier,
} from './decorators';

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
        return this.$schema.keys();
    }

    static get propertyOptions() {
        const options = {};
        this.$schema.forEach((val, name) => (options[name] = val.options));
        return options;
    }

    static get syncUrl() {
        invariant(this.identifiedBy, 'must have an identifiedBy property in order to calulate syncUrl');
        return `${Config.api_path}/${pluralize(this.identifiedBy)}`;
    }

    static get identifierName() {
        const field = find(this.$schema.values(), { type: 'identifier' });
        invariant(field, 'identifierName called on a model that has not designated one with `@identifier`');
        return field.name;
    }

    static get Collection() {
        return this.$collection || (this.$collection = new ModelCollection(this));
    }

    constructor(attrs) {
        if (!isEmpty(attrs)) { this.set(attrs); }
    }

    @observable syncInProgress = false;
    @observable lastServerMessage = '';
    @observable errors = {};

    @computed get errorMessage() {
        return toSentence(map(this.errors, (v, k) => `${humanize(k)} ${v}`));
    }

    @computed get isValid() {
        return isNil(this.errors) || isEmpty(this.errors);
    }

    @computed get isNew() {
        return isNil(this.identifier);
    }

    @computed get identifier() {
        return this[this.constructor.identifierName];
    }

    @computed get syncUrl() {
        const path = this.constructor.syncUrl;
        return this.isNew ? path : `${path}/${this.identifier}`;
    }

    set(attrs = {}) {
        assign(this, pick(attrs, this.constructor.assignableKeys));
        return this;
    }

    @action reset() {
        this.constructor.assignableKeys.forEach(k => (this[k] = null));
    }

    set syncData(data) {
        return this.update(data);
    }

    @computed
    get syncData() {
        return this.serialize();
    }

    fetch(options = {}) {
        invariant((!this.isNew || options.query),
                  'Unable to fetch record without it’s identifier being set or a query');
        const fetchOptions = extend(options, { limit: 1, method: 'GET' });
        if (!fetchOptions.query) {
            fetchOptions.query = { [`${this.constructor.identifierName}`]: this.identifier };
        }
        return Sync.forModel(this, fetchOptions);
    }

    save(options = {}) {
        return Sync.forModel(this, options);
    }

    destroy(options = {}) {
        return Sync.forModel(this, extend(options, { action: 'destroy' }));
    }
}

export default BaseModel;
