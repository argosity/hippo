import {
    BaseModel, model, session, computed,
} from '../models/base';


class ModelConfig {

    constructor(type, model) {
        this.type = type;
        this.id = model.getId();
        this.channel = `${_.result(model, 'api_path')}/${this.id}`;
        this.count = 0;
        this.models = [];
    }

    add(model) {
        if (this.count === 0) {
            __guard__(Lanes.Models.PubSub.channel, x => x.subscribe(this.channel)); //, @mbCallBack(@models))
        }
        this.count += 1;
        const config = this.modelConfig(model);
        return config.count += 1;
    }

    modelConfig(model) {
        let config = _.find(this.models, {model});
        if (!config) {
            config = {model, count: 0};
            this.models.push(config);
        }
        return config;
    }

    remove(model) {
        const config = _.find(this.models, {model});
        if (!config) { return; }
        this.count -= 1;
        if (this.count === 0) { // all removed, just unsubscribe
            return this.unsubscribe();
        } else {
            config.count -= 1;
            if (config.count === 0) { return _.remove(this.models, {model}); }
        }
    }

    unsubscribe() {
        __guard__(Lanes.Models.PubSub.channel, x => x.unsubscribe( this.channel ));
        return delete this.type.records[this.id];
    }

    onChange(data) {
        return Array.from(this.models).map((config) => config.model.addChangeSet(data));
    }
}

class ModelType {

    constructor(attr) {
        _.extend(this, attr);
        this.records = {};
    }

    add(model) {
        const config = this.records[model.id] || (this.records[model.id] = new ModelConfig(this, model));
        return config.add(model);
    }

    remove(model) {
        return __guard__(this.records[model.id], x => x.remove(model));
    }

    onChange(id, data) {
        return this.records[id].onChange(data);
    }

    unsubscribeAll() {
        return (() => {
            const result = [];
            for (let id in this.records) {
                const record = this.records[id];
                result.push(record.unsubscribe());
            }
            return result;
        })();
    }
}

class ModelTypesCollection extends BaseModel {
    static initClass() {
        this.prototype.model = ModelType;
    }
    constructor() { super(...arguments); }

    forModel(model) {
        let models;
        const path = _.result(model, 'api_path');
        return models = this.get(path) || this.add({id: path});
    }
}
ModelTypesCollection.initClass();


const CableChannel = {
    connected() {
        return this.subscribe('file-change', () => Lanes.lib.HotReload.initiate(changes));
    },

    subscribe(channel) {
        Lanes.log.info(`[pubsub] subscribe to: ${channel}`);

        return this.perform("on", {channel});
    },

    unsubscribe(channel) {
        Lanes.log.info(`[pubsub] unsubscribe from: ${channel}`);
        return this.perform("off", {channel});
    },

    received(data) {
        const [channel, prefix, model, id] = Array.from(data.channel.match(/^(.*)\:(.*)\/([^\/]+)$/));
        Lanes.log.info(`[pubsub] change recvd for: ${channel}`);
        return Lanes.Models.PubSub.onChange(
            model, id, _.omit(data, 'channel')
        );
    }

};

const PubSub = {

    types: new ModelTypesCollection,

    add(model) {
        if (!__guardMethod__(model, 'isPersistent', o => o.isPersistent())) { return; }
        return this.types.forModel(model).add(model);
    },

    remove(model) {
        if (!model || !__guardMethod__(model, 'isPersistent', o => o.isPersistent())) { return; }
        return this.types.forModel(model).remove(model);
    },

    instanceFor( model_klass, id ) {
        const path = _.result(model_klass.prototype, 'api_path');
        return __guard__(__guard__(__guard__(this.types.get(path), x2 => x2.records[id]), x1 => x1.models[0]), x => x.model);
    },

    clear() {
        return this.types = new ModelTypesCollection;
    },

    initialize() {
        Lanes.current_user.on('change:isLoggedIn', _.bind(this.onLoginChange, this));
        if (Lanes.current_user.isLoggedIn) { return this.onLoginChange(); }
    },

    onChange(path, id , data) {
        return this.types.get(path).onChange(id, data);
    },

    onLoginChange() {
        if (Lanes.current_user.isLoggedIn) {
            const url = `${Lanes.config.api_host}${Lanes.config.api_path}/ws`;
            this.cable = ActionCable.createConsumer(url);
            return this.channel = this.cable.subscriptions.create("Lanes::API::PubSub", CableChannel);
        } else {
            Lanes.Models.PubSub.types.each(t => t.unsubscribeAll());
            delete this.channel;
            this.cable.disconnect();
            return delete this.cable;
        }
    }

};

export function start() {
    //PubSub.initialize();
}

export function stop() {
    PubSub.kill()
}


function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}
