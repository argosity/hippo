import { get, compact, first, filter, find, uniqueId } from 'lodash';
import {
    BaseModel, identifiedBy, autorun, belongsTo, computed, observable,
} from '../base';

@identifiedBy('hippo/query/clause')
export default class Clause extends BaseModel {

    @observable id = uniqueId('clause');

    @observable value;
    @belongsTo({ type: 'hippo/query' }) query;

    @belongsTo({ type: 'hippo/query/field' }) field;
    @belongsTo({ type: 'hippo/query/operator' }) operator;

    @computed get description() {
        return compact([get(this, 'field.title'), get(this, 'operator.id')]).join(' ');
    }

    constructor(attrs) {
        super(attrs);
        this.field = first(this.query.info.queryableFields);
        autorun(this._updateOperatorOnFieldChange.bind(this));
    }

    @computed get validOperators() {
        return filter(this.query.operators, o => o.isValidForField(this.field));
    }

    @computed get fingerprint() {
        return [this.field.id, this.operator.id, this.value].join('-');
    }

    @computed get isValid() {
        return !!(this.value && this.operator.isValidForField(this.field));
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

    _updateOperatorOnFieldChange() {
        this.operator = find(this.query.operators, o => o.isValidForField(this.field));
    }
}
