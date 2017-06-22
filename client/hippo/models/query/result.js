import { isFunction } from 'lodash';

import {
    BaseModel,
    belongsTo,
    identifiedBy,
} from '../base';

@identifiedBy('hippo/query/result')
export default class Result extends BaseModel {
    @belongsTo({ type: 'hippo/query' }) query;

    sortingFunction() {
        const field = this.query.sortField;
        if (!field) { return false; }
        if (isFunction(field.sortBy)) { return field.sortBy; } return false;
    }

    loadFully() { return Promise.resolve(this); }
}
