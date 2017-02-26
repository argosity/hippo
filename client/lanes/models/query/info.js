import { map, filter, find, } from 'lodash';

import {
    BaseModel, modelDecorator, field, session,
    belongsTo, hasMany, identifier, computed, observable,
} from '../base';


export default class Info {

    constructor(query) {
        this.query = query;
    }

    @computed get syncUrl() {
        return this.query.customSyncUrl || this.query.src.syncUrl;
    }

    // the index of fields marked as visible
    @computed get visibleIndexes() {
        const indexes = [];
        this.query.fields.forEach((f, i) => { if (f.visible) { indexes.push(i); } });
        return indexes;
    }

    @computed get visibleFields() {
        return filter(this.query.fields, f => f.visible);
    }

    @computed get queryableFields() {
        return filter(this.query.fields, f => f.queryable);
    }

    @computed get loadableFields() {
        return filter(this.query.fields, f => f.loadable);
    }

    @computed get visibleIdentifierField() {
        const property = this.query.src.visibleIdentifier || this.query.src.identifierName;
        return find(this.query.fields, { id: property });
    }


}
