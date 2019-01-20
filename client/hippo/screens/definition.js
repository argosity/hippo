import Extensions from '../extensions';
import {
    BaseModel, identifiedBy, session, identifier, computed,
} from '../models/base';

import Instance, { displaying } from './instance';

import Registry from './index';
import Group from './group';

export asyncComponent from './async-loading';


@identifiedBy('hippo/screen/definition')
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
            const group = Group.forId(screen.group_id);
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

    @computed get instances() {
        return displaying.findInstance(this.id);
    }

    display() {
        let instance = displaying.findInstance(this.id); // this.instances[0];
        if (!instance) {
            instance = new Instance({ definition: this, isActive: true });
        }
        instance.isActive = true;
        return instance;
    }

}
