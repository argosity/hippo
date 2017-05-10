import { observable, observe } from 'mobx';
import { keysIn, pick, assign, get } from 'lodash';
import Extensions from './extensions';

const STORAGE_KEY = 'hippo-user-data';

class Config {

    @observable api_host = get(window, 'location.origin', '');
    @observable api_path = '/api';
    @observable access_token;
    @observable root_view;
    @observable assets_path_prefix = '/assets';
    @observable user;
    @observable screens;

    constructor() {
        this.bootstrapUserData();
        observe(this, 'user', ({ newValue }) => {
            if (newValue) { this.setUserData(); }
        });
        observe(this, 'screens', ({ newValue }) => {
            if (newValue) { this.setScreenData(); }
        });
        observe(this, 'access_token', ({ newValue: token }) => {
            this.data.token = token;
            this.persistToStorage();
        });
    }

    bootstrap(attrs) {
        assign(this, pick(attrs, keysIn(this)));
        Extensions.setBootstrapData(attrs);
    }

    persistToStorage() {
        window.localStorage.setItem(STORAGE_KEY, JSON.stringify(this.data));
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

    bootstrapUserData() {
        const savedData = window.localStorage.getItem(STORAGE_KEY);
        this.data = JSON.parse(savedData);
        if (!this.data) { return; }
        this.access_token = this.data.token;
        this.setUserData();
        this.setScreenData();
    }

    reset() {
        this.data = {};
        this.persistToStorage();
        this.access_token = null;
        if (this.user) { this.user.reset(); }
        if (this.screens) { this.screens.reset(); }
    }
}

const ConfigInstance = new Config();
export default ConfigInstance;
