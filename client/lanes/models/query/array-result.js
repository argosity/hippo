import { find, isEmpty, isNil, extend, map, bindAll, omit, range, wrap } from 'lodash';
import Sync from '../sync';
import Result from './result';
import {
    BaseModel,
    belongsTo,
    hasMany,
    computed,
    session,
    identifiedBy,
    observable,
    action,

} from '../base';

import { autorun, reaction } from 'mobx';

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

        //     console.log('React');
        //     return 1; // [this.query.sortField, this.query.sortAscending];
        // },
        //          this.onQuerySortChange(),
        //         );
                  // (sf, sa) => {
                  //     if ((sa !== this.query.sortAscending) || (sf !== this.query.sortField)) {

                  //     }
                  // }
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
    }

    isIndexSaved(index) {
        const row = this.rows[index];
        return (row && row[this.query.info.visibleIdentifierField.dataIndex]);
    }

    removeRow(index) {
        this.rows.splice(index, 1);
    }

    rowAsObject(index) {
        const row = this.rows[index];
        const obj = {};
        this.query.info.loadableFields.forEach(f => (obj[f.id] = row[f.dataIndex]));
        return obj;
    }

    modelForRow(index) {
        const model = new this.query.src(this.rowAsObject(index)); // eslint-disable-line new-cap
        model.save = wrap(
            model.save, (orig, options) =>
                orig.call(model, options).then(() => {
                    const row = this.rows[index];
                    this.query.info.loadableFields.forEach(
                        f => (row[f.dataIndex] = model[f.id]),
                    );
                    return model;
                }),
        );
        return model;
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

    // keyForRow(row) {
    //     return row[
    //         this.query.info.visibleIdentifierField.dataIndex
    //     ];
    // }


    // @computed get xDataColumn() {
    //     return find(this.query.fields, { query: true });
    // }

    // map(...args) {
    //     return this.rows.map(...args);
    // }

    // peek() {
    //     return this.rows.peek();
    // }

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

}  //// END OF CODE ////

    // xtraData(indexOrRow, options) {
    //     const row = _.isArray(indexOrRow) ? indexOrRow :
    //         this.pageForIndex(indexOrRow).rowAt(indexOrRow);
    //     if (!row[this.xDataColumn]) { row[this.xDataColumn] = {}; }
    //     if (options) { _.extend(row[this.xDataColumn], options); }
    //     return row[this.xDataColumn];
    // }


    // allRows(options) {
    //     const rows = (__range__(0, this.length, false).map(i => this.rowAt(i, options)));
    //     return _.Promise.resolve(rows);
    // }

    // eachRow(fn) {
    //     for (let i = 0, end = this.length, asc = 0 <= end; asc ? i < end : i > end; asc ? i++ : i--) {
    //         const row = this.rowAt(i);
    //         if ('break' === fn(row, row[this.xDataColumn], i)) { return i; }
    //     }
    // }

    // map(fn) {
    //     const rows = [];
    //     this.query.results.eachRow((row, xd, i) => rows.push(fn(row, xd, i)));
    //     return rows;
    // }

    // findById(id) {
    //     return this.eachRow((row, xd, i) => {
    //         if (id === this.idForRow(row)) { return 'break'; }
    //     },
    //     );
    // }

    // idForRow(row) {
    //     return row[this.query.idIndex];
    // }

    // filteredRows(fn) {
    //     const found = [];
    //     this.eachRow((row, xd) => {
    //         if (fn(row, xd)) { return found.push(row); }
    //     });
    //     return found;
    // }

    // modelAt(index) {
    //     return this.pageForIndex(index).modelAt(index);
    // }

    // saveModelChanges(model, index) {
    //     if (_.isUndefined(index)) {
    //         index = this.findById(model.getId());
    //     }
    //     this.pageForIndex(index).saveModelChanges(model, index);
    //     return this.query.markModified();
    // }

    // removeRow(index) {
    //     if (null == index) { index = 0; }
    //     this.total -= 1;
    //     return this.pageForIndex(index).removeRow(index);
    // }

    // addBlankRow(index) {
    //     if (null == index) { index = 0; }
    //     this.total += 1;
    //     return this.pageForIndex(index).addBlankRow(index);
    // }

    // ensureLoaded(options) {
    //     if (null == options) { options = {}; }
    //     return this.pageForIndex(options.page || 0).pendingLoad || _.Promise.resolve(this);
    // }

    // loadFully() {
    //     const len = this.length;
    //     const loading = [];

    //     for (let pageIndex = 0, end = len - 1, step = this.pageSize, asc = 0 < step; asc ? pageIndex < end : pageIndex > end; pageIndex += step) {
    //         const page = this.pageForIndex(pageIndex, { noLoad: true });
    //         if (!page.isLoaded()) { loading.push(page._load()); }
    //         null;
    //     }

    //     return _.Promise.all(loading);
    // }


    // reload(options) {
    //     if (null == options) { options = {}; }
    //     this.pages = [];
    //     this.total = 0;
    //     return this.ensureLoaded(options);
    // }

    // rowRepresentation(rowNum) {
    //     return this.pageForIndex(rowNum).rowAt(rowNum);
    // }

    // valueForField(row, field) {
    //     if (null != field.fetchIndex) { return row[field.fetchIndex]; } return undefined;
    // }

    // _updateSort() {
    //     const fn = this.sortingFunction();
    //     if (fn) {
    //         return this.allRows().then((rows) => {
    //             rows = _.sortBy(rows, _.bind(fn, this));
    //             rows = this.query.sortAscending ? rows.reverse() : rows;
    //             const page = new Page(0, this, { rows });
    //             this.pages = [page];
    //             this.query.markModified();
    //             return this;
    //         },
    //                                   );
    //     }
    //     return this.reload().then(() => {
    //         this.query.markModified();
    //         return this;
    //     },
    //                              );
    // }



// @identifiedBy('lanes/query/array-result/page')
// class Page extends BaseModel {

//     // @session pageNum;
//     // @session syncInProgress;
//     // @belongsTo result;

//     // constructor(attrs) {
//     //     super(attrs);
//     //     this.rows = attrs.rows || [];
//     //     this.pageNum = this.result.pages.length;
//     // }

//     // ensureLoaded() {
//     //     return (this.rows.length) ? Promise.resolve(this) : this.load();
//     // }

//     // map(fn) {
//     //     return map(this.rows, row => fn(row));
//     // }

//     isLoaded() { return !isNil(this.rows); }

//     normalizedIndex(index) {
//         return index % this.result.pageSize;
//     }

//     // N.B. for convenience the index for the methods below is the absolute index for all results
//     // not the index just for this page.  It's converted and the appropriate row returned
//     rowAt(index) {
//         return this.rows[this.normalizedIndex(index)] || [];
//     }

//     // _rowToModel(row) {
//     //     const attrs = {};
//     //     for (let i = 0; i < this.result.query.fields.models.length; i++) {
//     //         const field = this.result.query.fields.models[i];
//     //         if (field.query && (null != row[field.fetchIndex])) {
//     //             attrs[field.id] = row[field.fetchIndex];
//     //         }
//     //     }
//     //     return new this.result.query.src(attrs);
//     // }

//     // rowAt(index) {
//     //     return this._rowAt(index);
//     // }

//     // modelAt(index, options) {
//     //     const row = this._rowAt(index);
//     //     return this._rowToModel(row);
//     // }

//     // saveModelChanges(model, index) {
//     //     const row = this._rowAt(index);
//     //     return Array.from(this.result.query.fields.models).map((field, i) =>
//     //         row[field.fetchIndex] = model[field.id]);
//     // }

//     // addBlankRow(index) {
//     //     const model = new this.result.query.model();
//     //     const row = [];
//     //     for (let i = 0; i < this.result.query.fields.models.length; i++) {
//     //         const field = this.result.query.fields.models[i];
//     //         row[field.fetechIndex] = model[field.id];
//     //     }
//     //     this.rows.splice(this._normalizedIndex(index), 0, row);
//     //     return this._rowToModel(row);
//     // }

//     // removeRow(index) {
//     //     if (null == index) { index = 0; }
//     //     return this.rows.splice(this._normalizedIndex(index), 1);
//     // }
// }
