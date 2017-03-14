import {
    BaseModel, identifiedBy, session, belongsTo, identifier,
} from '../base';

@identifiedBy('lanes/query/operators/operator')
export default class Operator extends BaseModel {

    @identifier({ type: 'string' }) id;
    @session label;
    @session selected;

    @session({ type: 'array' }) types;
    @belongsTo({ model: 'lanes/query/field' }) field;

    isValidForField(field) {
        if (!field) { return false; }
        if (!this.types.length) { return true; }
        return !!this.types.find(t => t === field.queryType);
    }

}
