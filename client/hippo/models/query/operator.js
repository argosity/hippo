import {
    BaseModel, identifiedBy, session, belongsTo, identifier,
} from '../base';

@identifiedBy('hippo/query/operators/operator')
export default class Operator extends BaseModel {

    @identifier({ type: 'string' }) id;
    @session label;
    @session selected;

    @session({ type: 'array' }) types;
    @belongsTo({ model: 'hippo/query/field' }) field;

    isValidForField(field) {
        if ('eq' === this.id) { return true; }
        if (!field) { return false; }
        if (!this.types.length) { return true; }
        return !!this.types.find(t => t === field.queryType);
    }

}
