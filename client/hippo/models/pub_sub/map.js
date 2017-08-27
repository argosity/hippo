import invariant from 'invariant';
import { isEmpty, mapValues } from 'lodash';

export default class PubSubMap {
    constructor(modelKlass, channel) {
        this.channel = channel;
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
                this.channel.subscribe(channel);
            }
        }
    }

    remove(model) {
        const { id, models } = this.forModel(model);
        const indx = models.indexOf(model);
        invariant(-1 !== indx, 'Asked to remove model from pubsub but it was never observed');
        if (1 === models.length) {
            delete this.map[id];
            this.channel.unsubscribe(this.channelForId(id));
        } else {
            models.splice(indx, 1);
        }
    }
}
