import {
    isEmpty, isNil, extend, map, bindAll, omit, range, has,
} from 'lodash';
import { autorun, reaction, observe } from 'mobx';

import Sync from '../sync';
import Result from './result';
import {
    belongsTo, computed, identifiedBy, observable, action,
} from '../base';

@identifiedBy('lanes/query/array-result')
export default class ArrayResult extends Result {

    @belongsTo query;
    @observable updateKey;
    @observable totalCount = 0;
    @observable rows;
    @observable isLoading;

    @observable sortAscending;
    @observable sortField;

    constructor(attrs) {
        super(attrs);
        bindAll(this, 'onUpdated', 'onQuerySortChange');
        this.rows = observable.shallowArray([]);
        this.sortField = this.query.sortField;
        this.sortAscending = this.query.sortAscending;
        autorun(this.onUpdated);
        reaction(
            () => [this.query.sortField, this.query.sortAscending],
            this.onQuerySortChange,
        );
    }

    onUpdated() {
        this.updateKey = [
            this.rows.length,
            (this.sortField ? this.sortField.id : 'none'),
            this.sortAscending,
        ].join('-');
    }

    insertRow() {
        this.rows.unshift(Array(this.query.info.loadableFields.length));
        this.totalCount += 1;
    }

    isIndexSaved(index) {
        const row = this.rows[index];
        return (row && row[this.query.info.visibleIdentifierField.dataIndex]);
    }

    removeRow(index) {
        this.rows.splice(index, 1);
        this.totalCount -= 1;
    }

    rowAsObject(index) {
        const row = this.rows[index];
        const obj = {};
        this.query.info.loadableFields.forEach(f => (obj[f.id] = row[f.dataIndex]));
        return obj;
    }

    modelForRow(index) {
        const model = new this.query.src(this.rowAsObject(index)); // eslint-disable-line new-cap
        observe(model, 'syncData', ({ newValue: update }) => {
            const row = this.rows[index];
            this.query.info.loadableFields.forEach((f) => {
                if (has(update, f.id)) { row[f.dataIndex] = update[f.id]; }
            });
        });
        return model;
    }

    fetchModelForRow(index, syncOptions = {}) {
        const model = this.modelForRow(index);
        if (isEmpty(syncOptions) && isEmpty(this.query.syncOptions)) {
            return Promise.resolve(model);
        }
        return model.fetch(extend(syncOptions, this.query.syncOptions));
    }

    onQuerySortChange() {
        if ((this.sortAscending === this.query.sortAscending) &&
            (this.sortField === this.query.sortField)) {
            return;
        }
        this.sortField = this.query.sortField;
        this.sortAscending = this.query.sortAscending;
        if (isNil(this.sortField)) { return; }
        if (this.fullyLoaded) {
            this.sort();
        } else {
            this.reset().fetch();
        }
    }

    @action
    sort() {
        const asc = this.sortAscending;
        const index = this.sortField.dataIndex;
        this.rows.replace(this.rows.sort((ar, br) => {
            const [a, b] = [ar[index], br[index]];
            if (a === b) { return 0; }
            if (asc) {
                return (a > b) ? 1 : -1;
            }
            return (a < b) ? 1 : -1;
        }));
        return this;
    }

    @computed get fullyLoaded() {
        return this.totalCount === this.rows.length;
    }

    @action reset() {
        this.totalCount = 0;
        this.rows.clear();
        return this;
    }

    searchFieldValues(field, value) {
        const index = field.dataIndex;
        for (let x = 0; x < this.rows.length; x += 1) {
            if (this.rows[x][index] === value) {
                return { row: this.rows[x], index: x };
            }
        }
        return {};
    }

    isRowLoading(index) {
        return !!(this.rows.length > index && this.rows[index].isLoading);
    }

    fetch({ start = this.rows.length, limit = this.query.pageSize } = {}) {
        if (start + limit >= this.rows.length) {
            range(this.rows.length, start + limit).forEach(() => this.rows.push([]));
        }
        range(start, start + limit).forEach(i => (this.rows[i].isLoading = true));

        const query = {};
        this.query.clauses.forEach((clause) => {
            if (clause.isValid) {
                extend(query, clause.toParam());
            }
        });

        const options = {
            start,
            limit,
            total_count: 't',
            format: 'array',
            fields: map(this.query.info.loadableFields, 'id'),
        };

        if (!isEmpty(query)) {
            options.query = query;
        }

        if (!isNil(this.sortField)) {
            options.order = {
                [`${this.sortField.id}`]: (this.sortAscending ? 'asc' : 'desc'),
            };
        }

        extend(options, omit(this.query.info.syncOptions, 'include'));

        this.syncInProgress = options;

        return Sync.perform(this.query.info.syncUrl, options).then((resp) => {
            this.rows.splice(start, Math.max(limit, resp.data.length), ...resp.data);
            this.totalCount = resp.total;
            delete this.syncInProgress;
            return this;
        });
    }
}
