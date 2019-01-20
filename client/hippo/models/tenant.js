import { observable, computed } from 'mobx';
import { find, first } from 'lodash';
import {
    BaseModel, identifiedBy, field, identifier,
} from './base';
import Extensions from '../extensions';
import Subscription from './subscription';
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
        Extensions.fireOnInitialized();
        Tenant.current.update(data);
        if (data.bootstrap) {
            Config.update(data.bootstrap);
        }
        Extensions.fireOnAvailable();
    }

    @identifier({ type: 'string' }) identifier = 'current';

    @field name;

    @field email;

    @field slug;

    @field subscription_id;

    @computed get hasSubscription() {
        return Boolean(this.subscription);
    }

    @computed get domain() {
        return `${this.slug}.${Config.website_domain}`;
    }

    @computed get subscription() {
        return this.subscription_id
            ? find(Subscription.all, { id: this.subscription_id }) : null;
    }

    set syncData(data) {
        Tenant.bootstrap(data);
    }

    get syncData() {
        return this.serialize();
    }

}
