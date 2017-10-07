import { get, isString, find, extend, toPairs } from 'lodash';
import { toJS, action, reaction, observe, observable } from 'mobx';
import objectHash from 'object-hash';
import {
    BaseModel, identifiedBy, field, belongsTo, hasMany, identifier, computed, session,
} from './base';
import Info        from './query/info';
import Types       from './query/types';
import Operator    from './query/operator';
import Clause      from './query/clause';
import Field       from './query/field';
import ArrayResult from './query/array-result';

// needs to inherit from Base so network events will be listened to
@identifiedBy('hippo/query')
export default class Query extends BaseModel {

    @belongsTo src;

    @identifier id;
    @session pageSize = 20;

    @session initialField;
    @session idIndex;
    @session initialFieldIndex;

    @session sortField;
    @session sortAscending = false;

    @session results;
    @session customSyncUrl;

    @session autoFetch = false;
    @observable autoFetchDisposer;
    @field({ type: 'object' }) syncOptions = {};

    @hasMany({ model: Clause, inverseOf: 'query' }) clauses;
    @hasMany({ model: Operator, inverseOf: 'query' }) operators;
    @hasMany({ model: Field, inverseOf: 'query' }) fields;

    constructor(attrs = {}) {
        for (let i = 0; i < get(attrs, 'fields.length', 0); i += 1) {
            if (isString(attrs.fields[i])) {
                attrs.fields[i] = { id: attrs.fields[i] }; // eslint-disable-line no-param-reassign
            }
        }
        super(attrs);
        [
            { id: 'like', label: 'Starts With', types: Types.LIKE_QUERY_TYPES },
            { id: 'eq', label: 'Equals', types: Types.EQUAL_TYPES },
            { id: 'between', label: 'Between', types: Types.BETWEEN_TYPES },
            { id: 'contains', label: 'Contains', types: Types.LIKE_QUERY_TYPES },
            { id: 'lt', label: 'Less Than', types: Types.LESS_THAN_QUERY_TYPES },
            { id: 'gt', label: 'More Than', types: Types.LESS_THAN_QUERY_TYPES },

        ].forEach(op => this.operators.push(op));
        this.info = new Info(this);
        this.results = new ArrayResult({ query: this });
        if (0 === this.clauses.length) {
            const ff = find(this.fields, { queryable: true });
            if (ff) {
                this.clauses.push({ field: ff, operator: ff.preferredOperator });
            }
        }
        if (attrs.sort) {
            const [fieldId, dir] = toPairs(attrs.sort)[0];
            this.sortField = find(this.fields, { id: fieldId });
            this.sortAscending = ('ASC' === dir);
        }
        observe(this, 'autoFetch', this._onAutoFetchChange);
    }

    @action
    setSort({ field: f, ascending }) {
        this.sortField = f;
        this.sortAscending = ascending;
    }

    @computed get fingerprint() {
        return objectHash({
            so: toJS(this.syncOptions),
            c: this.info.valuedClauses.map(c => c.fingerprint),
        });
    }

    open() {
        if (this.autoFetch) { this._startAutoFetch(); }
    }

    close() {
        if (this.autoFetchDisposer) {
            this.autoFetchDisposer();
            this.autoFetchDisposer = null;
        }
    }

    @action.bound
    fetch() {
        return this.results.fetch({ start: 0 });
    }

    get rows() {
        return this.results.rows;
    }

    reset() {
        this.clauses.clear();
        this.results.reset();
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
            this.autoFetchDisposer = null;
        }
    }

    _startAutoFetch() {
        if (this.autoFetchDisposer) { return; }
        this.autoFetchDisposer = reaction(
            () => this.fingerprint,
            this.fetch,
            { delay: 100, compareStructural: true, fireImmediately: true },
        );
    }

}
