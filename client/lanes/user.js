import { pick, merge } from 'lodash';
import { action } from 'mobx';

import {
    BaseModel, identifiedBy, field, identifier, computed,
} from './models/base';

import Config from './config';

@identifiedBy('lanes/user-session')
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


@identifiedBy('lanes/user')
export class UserModel extends BaseModel {

    @identifier({ type: 'number' }) id;
    @field login;
    @field name;
    @field email;
    @field password;
    @field password_confirm;

    @field access;

    @computed get isLoggedIn() { return !!Config.access_token; }

    @action logout() {
        const req = new Session({ id: this.id });
        return req.destroy().then(() => {
            this.reset();
            Config.access_token = '';
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
            this.set(req.data.user);
            this.access = req.data.access;
            this.errors = {};
        }
        return this;
    }
}

const current_user = new UserModel();

export default current_user;
