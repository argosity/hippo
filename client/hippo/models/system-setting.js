import {
    BaseModel, identifiedBy, identifier, belongsTo, field, computed,
} from './base';
import Asset from './asset';

@identifiedBy('hippo/system-settings')
export default class SystemSettings extends BaseModel {

    @identifier id;

    @field({ type: 'object' }) settings;

    @belongsTo({ model: Asset, inverseOf: 'owner' }) logo;

    @belongsTo({ model: Asset, inverseOf: 'owner' }) print_logo;

    @computed get syncUrl() {
        return this.constructor.syncUrl;
    }

}
