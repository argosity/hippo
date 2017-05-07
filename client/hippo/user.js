import { pick, merge, includes } from 'lodash';
import { action } from 'mobx';

import {
    BaseModel, identifiedBy, field, identifier, computed,
} from './models/base';

import Config from './config';

@identifiedBy('hippo/user-session')
class Session extends BaseModel {
    @identifier id;
    @field login;
    @field password;

    set syncData(data) {
        this.data = data;
    }
    @computed
    get syncData() {
        return this.serialize();
    }
}

const ADMIN = 'administrator';

@identifiedBy('hippo/user')
export class UserModel extends BaseModel {

    @identifier({ type: 'number' }) id;
    @field login;
    @field name;
    @field email;
    @field password;
    @field password_confirm;
    @field({ type: 'array' }) role_names;
    @field({ type: 'object' }) access;

    set is_admin(val) {
        if (val) {
            if (!includes(this.role_names, ADMIN)) { this.role_names.push(ADMIN); }
        } else {
            this.role_names.remove(ADMIN);
        }
    }

    get is_admin() {
        return includes(this.role_names, ADMIN);
    }

    @computed get isLoggedIn() { return !!Config.access_token; }

    @action logout() {
        const req = new Session({ id: this.id });
        return req.destroy().then(() => {
            this.reset();
            Config.reset();
            return this;
        });
    }

    @action attemptLogin(login, password) {
        const req = new Session({ login, password });
        return req.save().then(this.setFromSessionRequest);
    }

    @action checkAccess() {
        const req = new Session({ id: 'test' });
        return req.fetch().then(this.setFromSessionRequest);
    }

    @action.bound
    setFromSessionRequest(req) {
        merge(this, pick(req, 'errors', 'lastServerMessage'));
        if (req.isValid) {
            Config.data = req.data;
            Config.persistToStorage();
            Config.bootstrapUserData();
            this.errors = {};
        }
        return this;
    }

    toJSON() {
        return merge(this.serialize(), { is_admin: this.is_admin });
    }

}

const current_user = new UserModel();
Config.user = current_user;

export default current_user;
