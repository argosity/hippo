import { get, includes } from 'lodash';
import { titleize } from '../../lib/util';
import {
    BaseModel, identifiedBy, session, belongsTo, identifier, computed, observable,
} from '../base';

@identifiedBy('hippo/query/field')
export default class Field extends BaseModel {
    @identifier({ type: 'string' }) id;
    @session title;
    @session selected   = false;
    @session editable   = true;
    @session width      = 100;
    @session flexGrow   = 1;
    @session flexShrink = 1;
    @session visible    = true;
    @session loadable   = true;
    @session queryable  = true;
    @session sortable   = true;
    @session textAlign  = 'left';
    @session dataType   = 'string'
    @session cellRenderer;
    @session defaultValue;
    @session fetchIndex;
    @session sortBy;

    @observable format;
    @observable component;
    @observable onColumnClick;

    @belongsTo query;

    @computed get isSortingBy() {
        return this === this.query.sortField;
    }

    @computed get label() {
        return this.title ? this.title : titleize(this.id);
    }

    @computed get queryType() {
        return get(this.query.src.propertyOptions[this.id], 'type', this.dataType);
    }

    @computed get isNumeric() {
        return includes(['number'], this.queryType);
    }

    @computed get dataIndex() {
        if (!this.loadable) { return null; }

        let index = 0;
        for (let i = 0; i < this.query.fields.length; i += 1) {
            if (this.query.fields[i].loadable) {
                if (this.query.fields[i] === this) {
                    return index;
                }
                index += 1;
            }
        }
        return null;
    }

    @computed get preferredOperator() {
        return this.query.operators.find(o => o.isValidForField(this));
    }
}
