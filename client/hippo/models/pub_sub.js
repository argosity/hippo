import { Atom, when, reaction } from 'mobx';
import ActionCable from 'actioncable';
import { BaseModel } from './base';
import User from '../user';
import Config from '../config';
import PubSubCableChannel from './pub_sub/channel';
import PubSubMap from './pub_sub/map';

const PubSub = {

    types: new WeakMap(),

    add(model) {
        return this.mapForModel(model).observe(model);
    },

    remove(model) {
        this.mapForModel(model).remove(model);
    },

    onModelChange(modelId, id, data) {
        const model = BaseModel.findDerived(modelId);
        if (!model) { return; }
        const map = this.types.get(model);
        if (map) {
            map.onChange(id, data);
        }
    },

    mapForModel(model) {
        const klass = model.constructor;
        let map = this.types.get(klass);
        if (!map) {
            map = new PubSubMap(klass, this.channel);
            this.types.set(klass, map);
        }
        return map;
    },


    onLoginChange() {
        if (User.isLoggedIn) {
            if (PubSub.cable) { return; }
            const host = Config.api_host.replace(/^http/, 'ws');
            const url = `${host}${Config.api_path}/cable?token=${Config.access_token}`;
            ActionCable.startDebugging();
            PubSub.cable = new ActionCable.Consumer(url);
            PubSub.channel = new PubSubCableChannel(PubSub);
        } else if (PubSub.cable) {
            PubSub.cable.disconnect();
            delete PubSub.cable;
            delete PubSub.channel;
        }
    },

};

export default PubSub;

export function onBoot() {
    PubSub.onLoginChange();
}

when(
    () => Config.isIntialized,
    () => {
        reaction(
            () => User.isLoggedIn,
            PubSub.onLoginChange,
            { fireImmediately: true },
        );
    },
);

export function stop() {
    PubSub.kill();
}

export class PubSubAtom {

    constructor(model) {
        this.model = model;
        if (model.identifierFieldValue) {
            this.buildAtom();
        } else {
            when(
                () => model.identifierFieldValue,
                () => this.buildAtom(),
            );
        }
    }

    buildAtom() {
        this.atom = new Atom(
            'ModelPubSub',
            () => PubSub.add(this.model),
            () => PubSub.remove(this.model),
        );
    }

    reportObserved() {
        if (this.atom) { this.atom.reportObserved(); }
    }

}

export function observePubSub(...models) {
    if (!PubSub.channel) { return; }
    for (let i = 0; i < models.length; i += 1) {
        const model = models[i];
        if (!model.$pubSub) {
            model.$pubSub = new PubSubAtom(model);
        }
        model.$pubSub.reportObserved();
    }
}
