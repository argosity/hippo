import { observable, computed } from 'mobx';
import { first } from 'lodash';
import {
    BaseModel, identifiedBy, field, identifier,
} from './base';
import Config from '../config';

const CACHED = observable.box();

@identifiedBy('hippo/tenant')
export default class Tenant extends BaseModel {

    @computed static get current() {
        let tenant = CACHED.get();
        if (!tenant) {
            tenant = new Tenant({
                slug: first(window.location.host.split('.')),
            });
            CACHED.set(tenant);
        }
        return tenant;
    }

    static bootstrap(data) {
        Tenant.current.update(data);
        if (data.bootstrap) {
            Config.update(data.bootstrap);
        }
    }

    @identifier({ type: 'string' }) identifier = 'current';
    @field name;
    @field email;
    @field slug;


    @computed get domain() {
        return `${this.slug}.${Config.website_domain}`;
    }

    set syncData(data) {
        Tenant.bootstrap(data);
    }

}
