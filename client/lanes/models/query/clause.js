import { get, compact, first, filter, find } from 'lodash';

import {
    BaseModel, identifiedBy, field, session, autorun,
    belongsTo, hasMany, identifier, computed, observable,
} from '../base';



@identifiedBy('lanes/query/clause')
export default class Clause extends BaseModel {


    @observable value;
    @belongsTo({ type: 'lanes/query' }) query;

    @belongsTo({ type: 'lanes/query/field' }) field;
    @belongsTo({ type: 'lanes/query/operator' }) operator;

    @computed get description() {
        return compact([get(this, 'field.title'), get(this, 'operator.id')]).join(' ');
    }

    constructor(attrs) {
        super(attrs);
        this.field = first(this.query.info.queryableFields);

// //        this.fields.reset(attrs.available_fields.models);
// //        this.operator = this.query.operators.find(e => e.selected: true });

//         // if (field = this.fields.findWhere({ visible: true })) {
//         //     field.selected = true;
//         //     this.setField(field);
//         // }
        autorun(this.setOperatorOnFieldChange.bind(this));
    }

    @computed get validOperators() {
        return filter(this.query.operators, o => o.isValidForField(this.field));
    }

    @computed get isValid() {
        return !!(this.value && this.operator.isValidForField(this.field));
    }


    setOperatorOnFieldChange() {
        this.operator = find(this.query.operators, o => o.isValidForField(this.field));
    }

    toParam() {
        const param = {};
        const op = this.operator.id;
        let value = this.value;
        if ('like' === op) { value += '%'; }
        if ('n' === this.field.type) { value = parseFloat(value); }
        param[this.field.id] = 'eq' === op ? value : { op, value };
        return param;
    }

    // setFromView(type, val) {
    //     if (('fields' === type) || ('operators' === type)) {
    //         return this[type].get(val).selected = true;
    //     } else {
    //         return super.setFromView(...arguments);
    //     }
    // }

    // setField(field) {
    //     if (!field.selected) { return; }
    //     this.operators.setField(field);
    //     return this.field = field;
    // }

    // setOperator(operator) {
    //     if (!operator.selected) { return; }
    //     return this.operator = operator;
    // }

    // remove() {
    //     return this.collection.remove(this);
    // }


}


// export default class Clauses extends BaseModel {

//     // static initClass() {
//     //     this.prototype.model = Clause;

//     //     this.prototype.session =
//     //         { field: 'state' };
//     // }

//     // initialize(models, options) {
//     //     super.initialize(...arguments);
//     //     this.query = options.query;
//     //     return this.fields = options.query.fields;
//     // }
// }
