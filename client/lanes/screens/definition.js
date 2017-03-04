import { autorun, observable } from 'mobx';
import { get, delay, extend, filter, map, uniq } from 'lodash';

import { classify, logger } from '../lib/util';
import Config from '../config'
import RequestAssets from '../lib/request-assets';
import Extensions from '../extensions';
import {
    BaseModel, modelDecorator, session,
    belongsTo, identifier, computed,
} from '../models/base';
import User from '../user';
import Instance, { displaying } from './instance';
import Group from './group';

import { createAsyncComponent } from 'react-async-component';

export { createAsyncComponent };
import Registry from './index';

import Groups from './group';

@modelDecorator('lanes/screen/definition')
export default class ScreenDefinition extends BaseModel {

    @identifier({ type: 'string' }) id;
    @session title;
    @session url_prefix;
    @session description;
    @session view;
    @session icon;
    @session group_id;
    @session access;
    @session isLoading = false;
    @session extension_id;
    @session model;
    @session({ type: 'object' }) component;
    @session asset;

    @session url;

    static register(json, comp) {
        let screen = Registry.all.get(json.id);
        if (screen) {
            screen.update(json);
        } else {
            screen = new ScreenDefinition(json);
            Registry.all.set(screen.id, screen);
            const group = Groups.forId(screen.group_id);
            if (group) { group.screens.push(screen); }
        }
        screen.component = comp;
        return screen;
    }

    @computed get extension() {
        return Extensions.get(this.extension_id);
    }

    @computed get model_type() {
        return BaseModel.findDerived(this.model);
    }

    // load(cb) {
    //     this.loadFn((comp) => {
    //         this.component = comp.default ? comp.default : comp;
    //         cb(this.component);
    //     });
    // }

    @computed get instances() {
        return displaying.findInstance(this.id); // displaying, instance => (instance.screen === this));
    }

    display() {
        let instance = displaying.findInstance(this.id); //this.instances[0];
        if (!instance) {
            instance = new Instance({ definition: this, isActive: true });
        }
        instance.isActive = true;
        return instance;
    }

//    loadScreen() {

        // return new Promise((resolve, reject) => {
        //     this.isLoading = true;
        //     let attempt = 0;
        //     const onViewLoaded = (view) => {
        //         this.isLoading = false;
        //         resolve(view);
        //     };
        //     const done = () => {
        //         if (this.screen) {
        //             onViewLoaded(this.screen);
        //         } else if (attempt < 3) {
        //             attempt += 1;
        //             delay(done, 500 * attempt);
        //         } else {
        //             reject(`Screen ${this.view} not definied after file retrieval`);
        //         }
        //     };
        //     const err = (msg) => {
        //         logger.warn(msg);
        //         this.isLoading = false;
        //         reject(msg);
        //     };
        //     return RequestAssets(...this.asset_paths).then(done, err);
        // });
//    }
    // display(defaultProps) {
    //     const props = extend({}, defaultProps, { screen: this });
    //     const display = (resolve) => {
    //         const sv = new ScreenView(props);
    //         sv.active = true;
    //         return resolve(sv);
    //     };
    //     return this.ensureLoaded().then(() =>
    //         new Promise((resolve) => {
    //             if (Lanes.current_user.isLoggedIn) {
    //                 return display(resolve);
    //             } else {
    //                 return Lanes.current_user.on('change:isLoggedIn', () => display(resolve));
    //             }
    //         })
    //     );
    // }
}
