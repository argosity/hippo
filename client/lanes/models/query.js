import { get, isString, extend } from 'lodash';
import { action, reaction, observe } from 'mobx';
import {
    BaseModel, identifiedBy, field, belongsTo, hasMany, identifier, computed, observable,
} from './base';

import Info        from './query/info';
import Types       from './query/types';
import Operator    from './query/operator';
import Clause      from './query/clause';
import Field       from './query/field';
import ArrayResult from './query/array-result';

// needs to inherit from Base so network events will be listened to
@identifiedBy('lanes/query')
export default class Query extends BaseModel {

    @belongsTo src;

    @identifier id;
    @observable pageSize = 20;

    @observable initialField;
    @observable idIndex;
    @observable initialFieldIndex;

    @observable sortField;
    @observable sortAscending = false;

    @observable results;
    @observable customSyncUrl;

    @observable autoFetch = false;

    @field({ type: 'object' }) syncOptions = {};

    @hasMany({ model: Clause, inverseOf: 'query' }) clauses;
    @hasMany({ model: Operator, inverseOf: 'query' }) operators;
    @hasMany({ model: Field, inverseOf: 'query' }) fields;

    @action
    setSort({ field: f, ascending }) {
        this.sortField = f;
        this.sortAscending = ascending;
    }

    constructor(attrs = {}) {
        for (let i = 0; i < get(attrs, 'fields.length', 0); i += 1) {
            if (isString(attrs.fields[i])) {
                attrs.fields[i] = { id: attrs.fields[i] }; // eslint-disable-line no-param-reassign
            }
        }
        super(attrs);
        [
            { id: 'like', label: 'Starts With', types: Types.LIKE_QUERY_TYPES },
            { id: 'eq', label: 'Equals' },
            { id: 'lt', label: 'Less Than', types: Types.LESS_THAN_QUERY_TYPES },
            { id: 'gt', label: 'More Than', types: Types.LESS_THAN_QUERY_TYPES },
        ].forEach(op => this.operators.push(op));
        this.info = new Info(this);
        this.results = new ArrayResult({ query: this });
        if (0 === this.clauses.length) {
            this.clauses.push({ });
        }
        if (this.autoFetch) { this._startAutoFetch(); }
        observe(this, 'autoFetch', this._onAutoFetchChange);
    }

    @computed get fingerprint() {
        return this.clauses.map(o => o.fingerprint).join(';');
    }

    @action.bound
    fetch() {
        return this.results.fetch({ start: 0 });
    }

    fetchSingle(query, queryOptions = {}) {
        const options = extend(queryOptions, this.syncOptions, { query });
        const { src: Src } = this;
        const model = new Src();
        return model.fetch(options);
    }

    @action.bound
    _onAutoFetchChange(change) {
        if (change.newValue) {
            this._startAutoFetch();
        } else if (this.autoFetchDisposer) {
            this.autoFetchDisposer();
        }
    }

    _startAutoFetch() {
        this.autoFetchDisposer = reaction(
            () => this.fingerprint,
            this.fetch,
            { delay: 100, compareStructural: true, fireImmediately: true },
        );
    }
}
