import {
    findModel
} from 'mobx-decorated-models';
import invariant from 'invariant';
import {
    isEmpty, isNil, find, invoke, get, extend, merge, assign, pick,
} from 'lodash';

import { action, observable, computed, autorun } from 'mobx';
import { capitalize, singular, underscored } from '../lib/util';
import pluralize from 'pluralize';

import Sync from './sync';
import Config from '../config';
import ModelCollection from './collection';

export {
    modelDecorator, belongsTo, hasMany,
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

    set(attrs) {
        assign(this, pick(attrs, this.constructor.assignableKeys));

        // this.constructor.replaceableKeys.forEach((key) => {
        //     if (attrs[key]) { this[key].replace(attrs[key]); }
        // });
        // return this;
    }

    @action reset() {
        this.constructor.assignableKeys.forEach(k => (this[k] = null));
        this.constructor.replaceableKeys.forEach((key) => {
            this[key].reset();
        });
    }

    setFromSync(data) {
        return this.update(data);
    }

    dataForSync() {
        return this.serialize();
    }

    fetch(options = {}) {
        invariant((!this.isNew), 'Unable to fetch record without it’s identifier being set');
        return Sync.forModel(
            this, merge(options, {
                limit:  1,
                method: 'GET',
                query:  { [`${this.constructor.identifierName}`]: this.identifier },
            }),
        );
    }

    save(options = {}) {
        return Sync.forModel(this, options);
    }

    destroy(options = {}) {
        return Sync.forModel(this, extend(options, { action: 'destroy' }));
    }
}
