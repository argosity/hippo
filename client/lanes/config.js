import { observable, autorun } from 'mobx';
import { keysIn, pick, assign, isString } from 'lodash';
import Extensions from './extensions';


class Config {

    @observable api_host = window.location.origin;
    @observable api_path = '/api';
    @observable access_token;
    @observable root_view;
    @observable assets_path_prefix = '/asset';

    constructor() {
        autorun(() => this.onTokenChange());
    }

    bootstrap(attrs) {
        assign(this, pick(attrs, keysIn(this)));
        Extensions.setBootstrapData(attrs);
    }

    onTokenChange() {
        /* global window: true  */
        if (!window.localStorage) { return; }
        if (isString(this.access_token)) {
            window.localStorage.setItem('token', this.access_token);
        } else {
            this.access_token = window.localStorage.getItem('token');
        }
        /* global window: false  */
    }
}

const ConfigInstance = new Config();
export default ConfigInstance;
