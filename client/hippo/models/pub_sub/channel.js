import { omit } from 'lodash';
import { action } from 'mobx';
import { logger } from '../../lib/util';
import { BaseModel } from '../base';

const CHANNEL_SPLITTER = new RegExp('^(.*):(.*)/([^/]+)$');

export default class PubSubCableChannel {
    constructor(pub_sub) {
        this.channel = pub_sub.cable.subscriptions.create(
            'Hippo::API::PubSub', this,
        );
        this.channel.received = this.received;
        this.pub_sub = pub_sub;
    }

    subscribe(channel) {
        logger.info(`[pubsub] subscribe to: ${channel}`);
        this.channel.perform('on', { channel });
    }

    unsubscribe(channel) {
        logger.info(`[pubsub] unsubscribe from: ${channel}`);
        this.channel.perform('off', { channel });
    }

    @action.bound
    received(data) {
        const [_, __, modelId, id] = Array.from(
            data.channel.match(CHANNEL_SPLITTER),
        );

        const model = BaseModel.findDerived(modelId);
        this.pub_sub.onModelChange(model, id, omit(data, 'channel'));
    }
}
