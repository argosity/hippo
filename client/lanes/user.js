import { pick, merge, bindAll } from 'lodash';
import { action } from 'mobx';

import {
    BaseModel, modelDecorator, field, session, identifier, computed,
} from './models/base';

import Config from './config';

@modelDecorator('lanes/user-session')
class Session extends BaseModel {
    @identifier id;
    @field login;
    @field password;
    setFromSync(data) {
        this.data = data;
    }
}


@modelDecorator('lanes/user')
export class User extends BaseModel {

    @identifier({ type: 'number' }) id;
    @field login;
    @field name;
    @field email;
    @field password;
    @field password_confirm;

    @field access;

    @computed get isLoggedIn() { return !!Config.access_token; }

    constructor(attrs = {}) {
        super(attrs);
        bindAll(this, 'setFromSessionRequest');
    }

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

const current_user = new User();

export default current_user;


    //     static initClass() {

    //         this.prototype.derived = {
    //             roles: {
    //                 fn() { return []; }
    //             },
    //             isLoggedIn: {
    //                 fn() { return false; }
    //             },
    //             allRoles: {
    //                 fn() { return new Lanes.Models.Role.Collection; }
    //             }
    //         };

    //         this.prototype.session = {
    //             access_data: 'object',
    //             id:          'integer',
    //             login:       'string',
    //             name:        'string',
    //             email:       'string',
    //             role_names:  'array',
    //             options:     'object',
    //             password:    'string'
    //         };
    //     }

    //     constructor(attributes, access) {
    //         super(...arguments);
    //         this.access_data = access;
    //     }

    //     api_path() { return '/users'; }
    //     hasAccess() { return true; }
    //     canRead(model, field) { return true; }
    //     canWrite(model, field) { return true; }
    //     canDelete(model)        { return true; }
    // };
    // undefined.initClass();


// let CURRENT_USER = null;

// Object.defineProperty(Lanes, 'current_user', {

//     set(user) {
//         let events = null;
//         if (CURRENT_USER) {
//             events = CURRENT_USER._events;
//         }
//         if (_.some(events)) {
//             for (let key in events) {
//                 const callbacks = events[key];
//                 if (user._events[key]) {
//                     user._events[key] = user._events[key].concat(callbacks);
//                 } else {
//                     user._events[key] = callbacks;
//                 }
//             }
//         }
//         return CURRENT_USER = user;
//     },

//     get() {
//         return CURRENT_USER;
//     }
// });
