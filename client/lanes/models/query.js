import { filter, get, isString } from 'lodash';
import {
    BaseModel, modelDecorator, field, session,
    belongsTo, hasMany, identifier, computed, observable,
} from './base';
import { autorun, action } from 'mobx';

import Info        from './query/info';
import Types       from './query/types';
import Operator    from './query/operators';
import Clause      from './query/clause';
import Field       from './query/field';
import ArrayResult from './query/array-result';

// needs to inherit from Base so network events will be listened to
@modelDecorator('lanes/query')
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
            { id: 'like', name: 'Starts With', types: Types.LIKE_QUERY_TYPES },
            { id: 'eq', name: 'Equals' },
            { id: 'lt', name: 'Less Than', types: Types.LESS_THAN_QUERY_TYPES },
            { id: 'gt', name: 'More Than', types: Types.LESS_THAN_QUERY_TYPES },
        ].forEach(op => this.operators.push(op));
        this.info = new Info(this);
        this.results = new ArrayResult({ query: this });
        if (0 === this.clauses.length) {
            this.clauses.push({ });
        }
    }

    fetch() {
        return this.results.fetch();
    }


    //     pageSize          : { type: 'number', default: 100 },
    //     syncOptions       : 'any',
    //     autoRetrieve      : { type: 'boolean', default: false, required: true },
    //     title             : { type: 'string', default: 'Find Record' },
    //     sortField         : 'object',
    //     defaultSort       : 'any',
    //     changeCount       : { type: 'integer', default: 0 },
    //     sortAscending     : ['boolean', true, true],
    // };


    //     this.prototype.associations = {
    //         fields  : { collection: AvailableFields, inverse: 'query' },
    //         clauses : { collection: Clauses, inverse: 'query' },
    //     };

    //     this.prototype.derived = {
    //         isCollection: {
    //             deps: ['src'], fn() { return Lanes.u.isCollection(this.src); },
    //         },

    //         model: {
    //             deps: ['src'], fn() {
    //                 if (!this.src) { return null; }
    //                 if (this.isCollection) { return this.src.model; } else { return this.src; }
    //             },
    //         },

    //         idAttribute: {
    //             deps: ['model'], fn() { return this.model.prototype.idAttribute; },
    //         },

    //         results: {
    //             deps: ['src'], fn() {
    //                 if (this.isCollection) {
    //                     return new Lanes.Models.Query.CollectionResult(this);
    //                 } else {
    //                     return new Lanes.Models.Query.ArrayResult(this, { pageSize: this.pageSize });
    //                 }
    //             },
    //         },
    //     };

    //     this.prototype.events = {
    //         'change:sortField'     : '_updateSort',
    //         'change:sortAscending' : '_updateSort',
    //     };

    //     this.prototype._updateSort = _.debounce(function () {
    //         return this.results._updateSort();
    //     });
    // }

    // static mergedSyncOptions(...args) {
    //     return _.merge({}, ...args, (a, b) => {
    //         if (_.isArray(a)) { return a.concat(b); }
    //     });
    // }

    // constructor(options) {
    //     if (null == options) { options = {}; }
    //     super(...arguments);

    //     this.fields.reset();
    //     for (let i = 0; i < options.fields.length; i++) {
    //         const col = options.fields[i];
    //         const rec = _.isObject(col) ? col : { id: col };
    //         this.fields.add(rec);
    //         if (rec.id === this.idAttribute) { this.idIndex = i; }
    //     }
    //     if (null == this.idIndex) {
    //         this.idIndex = this.fields.length;
    //         this.fields.add({ id: this.idAttribute });
    //     }
    //     // @clauses = new Clauses([], query: this )
    //     this.listenTo(this.clauses, 'change remove reset', () => {
    //         this.results.reset();
    //         if (this.autoRetrieve) { return this.results.ensureLoaded(); }
    //     },
    //     );
    //     this.on('change:src change:results', function () {
    //         return this.trigger('load');
    //     });
    //     this.on('load', function () {
    //         return this.changeCount += 1;
    //     });

    //     if (this.initialFieldIndex) {
    //         this.initialField = this.fields.visible.at(this.initialFieldIndex);
    //     }

    //     if (!this.initialField) {
    //         this.initialField = this.fields.visible.findWhere({ id: 'code' }) ||
    //         this.fields.visible.findWhere({ id: 'visible_id' }) ||
    //         this.fields.visible.first();
    //     }
    //     this.reset(true);
    //     this;
    // }

    // clonedAttributes() {
    //     const attrs = this.getAttributes({ session: true, derived: false });
    //     attrs.fields = this.fields.serialize({ session: true });
    //     return attrs;
    // }

    // markModified() { return this.changeCount += 1; }

    // reset(silent) {
    //     if (null == silent) { silent = false; }
    //     if (false !== this.defaultSort) {
    //         const sort = this.defaultSort || this.fields.findWhere({ visible: true }).id;
    //         this.setSortField(this.fields.findWhere({ id: sort }), { sortAscending: this.sortAscending, silent: true });
    //     }

    //     return this.clauses.reset([
    //         { query: this, available_fields: this.fields, field: this.initialField },
    //     ], { silent });
    // }

    // setSortField(field, options) {
    //     if (null == options) { options = { silent: false }; }
    //     if (null == options.sortAscending) { options.sortAscending = (this.sortField === field ? !this.sortAscending : true); }
    //     return this.set({
    //         sortAscending : options.sortAscending,
    //         sortField     : field,
    //     }, options);
    // }

    // ensureLoaded() { return this.results.ensureLoaded(); }

    // isValid() {
    //     return !this.clauses.findWhere({ isValid: false });
    // }

    // loadModel(model, options) {
    //     if (null == options) { options = {}; }
    //     _.extend(options, _.result(this, 'syncOptions'), { force: true });
    //     return model.withAssociations(options.include || [], options);
    // }

    // loadSingle(code, options) {
    //     if (null == options) { options = {}; }
    //     options.query = {};
    //     options.query[this.initialField.id] = code;
    //     _.extend(options, _.result(this, 'syncOptions'));
    //     this.trigger('request');
    //     return this.src.fetch(options).then((model) => {
    //         this.trigger('load');
    //         return model;
    //     },
    //     );
    // }

    // defaultField() {
    //     return this.fields.findWhere({ field: this.initialField });
    // }

    // addNewClause() {
    //     return this.clauses.add({ query: this, available_fields: this.fields, field: this.initialField });
    // }
}


// function __guard__(value, transform) {
//     return ('undefined' !== typeof value && null !== value) ? transform(value) : undefined;
// }
