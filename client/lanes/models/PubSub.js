import { find, remove, extend } from 'lodash';
import { logger } from '../lib/logger';
import {
    BaseModel,
} from '../models/base';

import User from '../user';
import Config from '../config';

const ActionCable  = {};

class ModelConfig {

    constructor(type, model) {
        this.type = type;
        this.id = model.getId();
        this.channel = `${model.identifiedBy}/${this.id}`;
        this.count = 0;
        this.models = [];
    }

    add(model) {
        if (0 === this.count) {
//            Lanes.Models.PubSub.channel.subscribe(this.channel);
            // __guard__(Lanes.Models.PubSub.channel, x => x
//                .subscribe(this.channel)); // , @mbCallBack(@models))
        }
        this.count += 1;
        const config = this.modelConfig(model);
        return (config.count += 1);
    }

    modelConfig(model) {
        let config = find(this.models, { model });
        if (!config) {
            config = { model, count: 0 };
            this.models.push(config);
        }
        return config;
    }

    remove(model) {
        const config = find(this.models, { model });
        if (!config) { return null; }
        this.count -= 1;
        if (0 === this.count) { // all removed, just unsubscribe
            return this.unsubscribe();
        }
        config.count -= 1;
        if (0 === config.count) { return remove(this.models, { model }); }
        return null;
    }

    unsubscribe() {
        // __guard__(Lanes.Models.PubSub.channel, x => x.unsubscribe(this.channel));
        return delete this.type.records[this.id];
    }

    onChange(data) {
        return Array.from(this.models).map(config => config.model.addChangeSet(data));
    }
}

class ModelType {

    constructor(attr) {
        extend(this, attr);
        this.records = {};
    }

    add(model) {
        const config = this.records[model.id] || (
            this.records[model.id] = new ModelConfig(this, model)
        );
        return config.add(model);
    }

    remove(model) {
        return this.records[model.id] && this.records[model.id].remove(model);
    }

    onChange(id, data) {
        return this.records[id].onChange(data);
    }

    unsubscribeAll() {
        return (() => {
            const result = [];
            this.recoards.forEach((record) => {
                result.push(record.unsubscribe());
            });
            return result;
        })();
    }
}

class ModelTypesCollection extends BaseModel {
    static initClass() {
        this.prototype.model = ModelType;
    }

    forModel(model) {
        const path = model.identifiedBy;
        return this.get(path) || this.add({ id: path });
    }
}
ModelTypesCollection.initClass();

const CableChannel = {};

const PubSub = {

    types: new ModelTypesCollection(),

    add(model) {
        //        if (!__guardMethod__(model, 'isPersistent',
        // o => o.isPersistent())) { return; }
        return this.types.forModel(model).add(model);
    },

    remove(model) {
        // if (!model || !__guardMethod__(model, 'isPersistent',
        //  o => o.isPersistent())) { return; }
        return this.types.forModel(model).remove(model);
    },

    // instanceFor(model_klass, id) {
    //     // const path = _.result(model_klass.prototype, 'api_path');
    //     //return __guard__(__guard__(__guard__(this.types.get(path),
    //     // x2 => x2.records[id]), x1 => x1.models[0]), x => x.model);
    // },

    // clear() {
    //     return this.types = new ModelTypesCollection();
    // },

    // initialize() {
    //     Lanes.current_user.on('change:isLoggedIn', _.bind(this.onLoginChange, this));
    //     if (Lanes.current_user.isLoggedIn) { return this.onLoginChange(); }
    // },

    // onChange(path, id, data) {
    //     return this.types.get(path).onChange(id, data);
    // },

    onLoginChange() {
        if (User.isLoggedIn) {
            const url = `${Config.api_host}${Config.api_path}/ws`;
            this.cable = ActionCable.createConsumer(url);
            this.channel = this.cable.subscriptions.create(
                'Lanes::API::PubSub', CableChannel,
            );
        }
        PubSub.types.each(t => t.unsubscribeAll());
        delete this.channel;
        this.cable.disconnect();
        return delete this.cable;
    },

};

const CHANNEL_SPLITTER = new RegExp('^(.*):(.*)/([^/]+)$');

extend(CableChannel, {
    connected() {
//        return this.subscribe('file-change', () => HotReload.initiate(changes));
    },

    subscribe(channel) {
        logger.info(`[pubsub] subscribe to: ${channel}`);
        return this.perform('on', { channel });
    },

    unsubscribe(channel) {
        logger.info(`[pubsub] unsubscribe from: ${channel}`);
        return this.perform('off', { channel });
    },

    received(data) {
        const [channel, _, model, id] = Array.from(
            data.channel.match(CHANNEL_SPLITTER),
        );
        logger.info(`[pubsub] change recvd for: ${channel}`);
        PubSub.onChange(
            model, id, _.omit(data, 'channel'),
        );
    },

});

export function start() {
    // PubSub.initialize();
}

export function stop() {
    PubSub.kill();
}


function __guard__(value, transform) {
    return ('undefined' !== typeof value && null !== value) ? transform(value) : undefined;
}
function __guardMethod__(obj, methodName, transform) {
    if ('undefined' !== typeof obj && null !== obj && 'function' === typeof obj[methodName]) {
        return transform(obj, methodName);
    }
    return undefined;
}
