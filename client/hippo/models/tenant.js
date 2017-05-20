import { get } from 'lodash';
import { observable } from 'mobx';
import {
    BaseModel, identifiedBy, field, identifier, computed,
} from './base';

const CACHE = observable({
    Tenant: undefined,
});

@identifiedBy('hippo/tenant')
export default class Tenant extends BaseModel {

    static get subdomain() {
        return get(window, 'location.hostname', '').split('.')[0];
    }

    @computed static get current() {
        if (!CACHE.Tenant) {
            CACHE.Tenant = new Tenant();
            CACHE.Tenant.fetch({ query: 'current' });
        }
        return CACHE.Tenant;
    }

    @identifier id;
    @field slug = Tenant.subdomain;
    @field name;
}
