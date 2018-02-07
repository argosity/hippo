import { when, observable, observe } from 'mobx';
import { pickBy, assign, get, hasIn, isNil } from 'lodash';
import { persist, create as createHydrator } from 'mobx-persist';
import Extensions from '../extensions';

const STORAGE_KEY = 'hippo-user-data';

export default class Config {

    @persist @observable api_host = get(window, 'location.origin', '');
    @persist @observable api_path = '/api';
    @persist @observable access_token;
    @persist @observable root_view;
    @persist @observable assets_path_prefix = '/assets';
    @persist @observable print_path_prefix = '/print';
    @persist @observable asset_host;
    @persist @observable website_domain;
    @persist @observable product_name;
    @persist @observable support_email;

    @persist('list') @observable screen_ids = [];
    @persist @observable user_info;
    @persist('object') @observable logo;
    @observable user;
    @observable environment;
    @observable isIntialized = false;
    @observable subscription_plans = [];

    static create(hydrationConfig) {
        const hydrate = createHydrator(hydrationConfig);
        const ConfigInstance = new Config();
        hydrate('config', ConfigInstance).then(() => { ConfigInstance.isIntialized = true; });
        return ConfigInstance;
    }

    constructor() {
        observe(this, 'user', ({ newValue }) => {
            if (newValue) { this.setUserData(); }
        });
    }

    update(attrs) {
        when(
            () => this.isIntialized,
            () => {
                assign(this, pickBy(attrs, (v, k) => !isNil(v) && hasIn(this, k)));
                Extensions.setBootstrapData(attrs, this);
            },
        );
    }

    setScreenData() {
        if (this.screens && this.data) {
            this.screens.configure(this.data.screens);
        }
    }

    setUserData() {
        if (this.user && this.data) {
            this.user.set(this.data.user);
            this.user.access = this.data.access;
        }
    }

    reset() {
        this.data = {};
        this.access_token = null;
        if (this.user) { this.user.reset(); }
    }

}
