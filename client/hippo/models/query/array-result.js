import {
    isEmpty, isNil, extend, map, bindAll, inRange, find, range, isUndefined,
} from 'lodash';
import { reaction, observe, toJS } from 'mobx';
import objectHash from 'object-hash';
import Sync from '../sync';
import Result from './result';
import {
    belongsTo, computed, identifiedBy, observable, action,
} from '../base';

@identifiedBy('hippo/query/array-result')
export default class ArrayResult extends Result {

    @belongsTo query;
    @observable totalCount = 0;
    @observable rows;
    @observable rowUpdateCount = 0;
    @observable sortAscending;
    @observable sortField;
    @observable.shallow loadingRows = [];
    @observable syncInProgress;

    constructor(attrs) {
        super(attrs);
        bindAll(this, 'onQuerySortChange');
        this.rows = observable.shallowArray([]);
        this.sortField = this.query.sortField;
        this.sortAscending = this.query.sortAscending;

        reaction(
            () => [this.query.sortField, this.query.sortAscending],
            this.onQuerySortChange,
        );
    }

    @computed get fingerprint() {
        return objectHash({
            q: this.query.fingerprint,
            sy: toJS(this.syncInProgress),
            rl: this.rows.length,
            sf: (this.sortField ? this.sortField.id : 'none'),
            sa: this.sortAscending,
            ru: this.rowUpdateCount,
        });
    }

    createModel(attrs = {}) {
        return new this.query.src(attrs); // eslint-disable-line new-cap
    }

    insertRow({ index = 0, model = this.createModel(), observeSave = false }) {
        if (-1 === index) { index = this.rows.length; } // eslint-disable-line
        const row = Array(this.query.info.loadableFields.length);
        this.query.fields.forEach((f) => {
            if (!isUndefined(model[f.id])) { row[f.dataIndex] = model[f.id]; }
        });
        this.rows.splice(index, 0, row);
        this.totalCount += 1;
        if (observeSave) { this.observeModelSave(model, index); }
        return { model, index };
    }

    isIndexSaved(index) {
        const row = this.rows[index];
        return (row && row[this.query.info.identifierField.dataIndex]);
    }

    removeRow(index) {
        this.rows.splice(index, 1);
        this.totalCount -= 1;
    }

    rowAsObject(index) {
        const row = this.rows[index];
        const obj = {};
        this.query.info.loadableFields.forEach((f) => {
            const value = row[f.dataIndex] || f.defaultValue;
            if (!isNil(value)) { obj[f.id] = value; }
        });
        return obj;
    }

    observeModelSave(model, index) {
        observe(model, 'syncInProgress', ({ newValue, oldValue }) => {
            if (newValue && !oldValue && newValue.isUpdate) {
                newValue.whenComplete(() => {
                    const row = this.rows[index];
                    this.query.info.loadableFields.forEach((f) => {
                        if (!isUndefined(model[f.id])) { row[f.dataIndex] = model[f.id]; }
                    });
                    this.rowUpdateCount += 1;
                }, 99);
            }
        });
    }

    modelForRow(index) {
        const model = this.createModel(this.rowAsObject(index));
        this.observeModelSave(model, index);
        return model;
    }

    fetchModelForRow(index, syncOptions = {}) {
        const model = this.modelForRow(index);
        return model.isNew ? Promise.resolve(model) :
            model.fetch(extend({}, toJS(this.query.syncOptions), syncOptions));
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
        return !!find(this.loadingRows, ([start, end]) => inRange(index, start, end));
    }

    fetch({ start = this.rows.length, limit = this.query.pageSize } = {}) {
        const inProgress = [start, start + limit];
        this.loadingRows.push(inProgress);

        const query = {};
        this.query.clauses.forEach((clause) => {
            if (clause.isValid) {
                extend(query, clause.toParam());
            }
        });

        const options = extend({}, toJS(this.query.syncOptions), {
            start,
            limit,
            total_count: 't',
            format: 'array',
            fields: map(this.query.info.loadableFields, 'id'),
        });

        if (!isEmpty(query)) {
            options.query = query;
        }

        if (!isNil(this.sortField)) {
            options.order = {
                [`${this.sortField.id}`]: (this.sortAscending ? 'asc' : 'desc'),
            };
        }

        extend(options, toJS(this.query.info.syncOptions));

        this.syncInProgress = options;

        return Sync.perform(this.query.info.syncUrl, options).then((resp) => {
            const rows = resp.data || [];
            if (start > this.rows.length) {
                range(this.rows.length, start).forEach(() => this.rows.push([]));
            }
            this.rows.splice(start, Math.max(limit, rows.length), ...rows);
            this.totalCount = resp.total;
            this.loadingRows.remove(inProgress);
            this.syncInProgress = null;
            return this;
        });
    }

}
