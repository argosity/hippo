import { Atom, when, reaction } from 'mobx';
import ActionCable from 'actioncable';
import invariant from 'invariant';
import { isEmpty, invoke, mapValues } from 'lodash';
import { logger } from '../lib/util';
import User from '../user';
import Config from '../config';

import PubSubCableChannel from './pub_sub/channel';

let PubSub;

class PubSubMap {
    constructor(modelKlass) {
        this.channel_prefix = modelKlass.identifiedBy;
        this.map = Object.create(null);
    }

    channelForId(id) {
        return `${this.channel_prefix}/${id}`;
    }

    forModel(model) {
        const id = model[model.constructor.identifierFieldName];
        let models = this.map[id];
        if (!models) {
            models = [];
            this.map[id] = models;
        }
        return { id, models };
    }

    onChange(id, data) {
        const models = this.map[id];
        if (!isEmpty(models)) {
            const update = mapValues(data.update, '[1]');
            for (let i = 0; i < models.length; i += 1) {
                models[i].set(update);
            }
        }
    }

    observe(model) {
        const { id, models } = this.forModel(model);
        if (!models.includes(model)) {
            models.push(model);
            if (1 === models.length) {
                const channel = this.channelForId(id);
                PubSub.channel.subscribe(channel);
            }
        }
    }

    remove(model) {
        const { id, models } = this.forModel(model);
        const indx = models.indexOf(model);
        invariant(-1 !== indx, 'Asked to remove model from pubsub but it was never observed');
        if (1 === models.length) {
            delete this.map[id];
            PubSub.channel.unsubscribe(this.channelForId(id));
        } else {
            models.splice(indx, 1);
        }
    }
}

PubSub = {

    types: new WeakMap(),

    add(model) {
        return this.mapForModel(model).observe(model);
    },

    remove(model) {
        this.mapForModel(model).remove(model);
    },

    onModelChange(model, id, data) {
        const map = this.types.get(model);
        if (map) {
            map.onChange(id, data);
        }
    },

    mapForModel(model) {
        const klass = model.constructor;
        let map = this.types.get(klass);
        if (!map) {
            map = new PubSubMap(klass);
            this.types.set(klass, map);
        }
        return map;
    },


    onLoginChange() {
        if (User.isLoggedIn) {
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

export function onBoot() {
    reaction(
        () => User.isLoggedIn,
        PubSub.onLoginChange,
        { fireImmediately: true },
    );
}

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
    for (let i = 0; i < models.length; i += 1) {
        const model = models[i];
        if (!model.$pubSub) {
            model.$pubSub = new PubSubAtom(model);
        }
        model.$pubSub.reportObserved();
    }
}
