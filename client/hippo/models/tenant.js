import { observable } from 'mobx';
import {
    BaseModel, identifiedBy, field, identifier, computed,
} from './base';
import Config from '../config';


const CACHED = observable.box();

@identifiedBy('hippo/tenant')
export default class Tenant extends BaseModel {
    @computed static get current() {
        let tenant = CACHED.get();
        if (!tenant) {
            tenant = new Tenant();
            CACHED.set(tenant);
            tenant.fetch({ query: 'current' });
        }
        return tenant;
    }

    @identifier id;
    @field slug = Tenant.slug;
    @field name;

    @computed get domain() {
        return `${this.slug}.${Config.website_domain}`;
    }
}
