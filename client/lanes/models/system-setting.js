import { merge } from 'lodash';
import {
    BaseModel, identifiedBy, identifier, belongsTo, field, computed,
} from './base';
import Sync  from './sync';

@identifiedBy('lanes/system-settings')
export default class SystemSettings extends BaseModel {

    @identifier id;
    @field({ type: 'object' }) settings;

    @belongsTo({ model: 'lanes/asset', inverseOf: 'owner' }) logo;
    @belongsTo({ model: 'lanes/asset', inverseOf: 'owner' }) print_logo;

    fetch(options = {}) {
        return Sync.forModel(this, merge(options, { limit: 1, method: 'GET' }));
    }

    @computed get syncUrl() {
        return this.constructor.syncUrl;
    }

}
