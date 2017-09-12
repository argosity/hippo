import { omit } from 'lodash';
import { action, observable } from 'mobx';
import { logger } from '../../lib/util';

const CHANNEL_SPLITTER = new RegExp('^(.*):(.*)/([^/]+)$');

export default class PubSubCableChannel {

    constructor(pub_sub) {
        this.callbacks = observable.map();
        this.channel = pub_sub.cable.subscriptions.create(
            'Hippo::API::PubSub', this,
        );
        this.channel.received = this.received;
        this.pub_sub = pub_sub;
    }

    subscribe(channel, cb) {
        logger.info(`[pubsub] subscribe to: ${channel}`);
        if (cb) {
            const callbacks = this.callbacks.get(channel) || observable([]);
            callbacks.push(cb);
            this.callbacks.set(channel, callbacks);
        }
        this.channel.perform('on', { channel });
    }

    unsubscribe(channel, cb) {
        logger.info(`[pubsub] unsubscribe from: ${channel}`);
        if (cb) {
            const callbacks = this.callbacks.get(channel);
            if (callbacks) {
                callbacks.remove(cb);
                if (callbacks.length) {
                    this.callbacks.set(channel, callbacks);
                } else {
                    this.callbacks.delete(channel);
                }
            }
        } else {
            this.channel.perform('off', { channel });
        }
    }

    @action.bound
    received(data) {
        const [_, __, modelId, id] = Array.from(
            data.channel.match(CHANNEL_SPLITTER),
        );
        const callbacks = this.callbacks.get(`${modelId}/${id}`);
        if (callbacks) {
            callbacks.forEach(c => c(data));
        } else {
            this.pub_sub.onModelChange(modelId, id, omit(data, 'channel'));
        }
    }

}
