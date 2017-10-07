import { observable, observe } from 'mobx';
import { keysIn, pick, assign, get } from 'lodash';
import { persist, create as createHydrator } from 'mobx-persist';

import Extensions from '../extensions';

const STORAGE_KEY = 'hippo-user-data';

export default class Config {

    @persist @observable api_host = get(window, 'location.origin', '');
    @persist @observable api_path = '/api';
    @persist @observable access_token;
    @persist @observable root_view;
    @persist @observable assets_path_prefix = '/assets';
    @persist @observable website_domain;
    @persist @observable product_name;
    @persist('list') @observable screen_ids = [];
    @persist @observable user_info;
    @persist('object') @observable logo;
    @observable user;
    @observable isIntialized = false;

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
        assign(this, pick(attrs, keysIn(this)));
        Extensions.setBootstrapData(attrs);
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
