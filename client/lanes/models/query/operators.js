import {
    BaseModel, modelDecorator, session,
    belongsTo, identifier,
} from '../base';

import Types from './types';

@modelDecorator('lanes/query/operators/operator')
export default class Operator extends BaseModel {

    @identifier({ type: 'string' }) id;
    @session name;
    @session selected;

    @session({ type: 'array' }) types;
    @belongsTo({ model: 'lanes/query/field' }) field;

    isValidForField(field) {
        if (!field) { return false; }
        if (!this.types.length) { return true; }
        return !!this.types.find(t => t === field.queryType);
    }

}


// @modelDecorator('lanes/query/operators')
// export default class Operators extends BaseModel {

//     @session({ type: 'array' }) operators;

//     constructor() {
//         super();
//         [
//             { id: 'like', name: 'Starts With', types: Types.LIKE_QUERY_TYPES },
//             { id: 'eq', name: 'Equals' },
//             { id: 'lt', name: 'Less Than', types: Types.LESS_THAN_QUERY_TYPES },
//             { id: 'gt', name: 'More Than', types: Types.LESS_THAN_QUERY_TYPES },
//         ].forEach(op => this.operators.push(op));
//     }

//     setField(field) {
//         this.field = field;
//         this.valid = this.subcollection({ filter: op => op.validForField(this.field) });
//         const selected = this.findWhere({ selected: true });
//         if (!selected || !selected.validForField(field)) {
//             return __guard__(this.valid.at(0), x => x.selected = true);
//         }
//     }
// }
