import { omit } from 'lodash';

import { logger } from '../../lib/util';
import { BaseModel } from '../base';

const CHANNEL_SPLITTER = new RegExp('^(.*):(.*)/([^/]+)$');

export default class PubSubCableChannel {

    constructor(pub_sub) {
        this.channel = pub_sub.cable.subscriptions.create(
            'pubsub', this,
        );
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

    received(data) {
        const [channel, _, modelId, id] = Array.from(
            data.channel.match(CHANNEL_SPLITTER),
        );
        logger.info(`[pubsub] change recvd for: ${channel}`);
        const model = BaseModel.findDerived(modelId);
        this.pub_sub.onModelChange(model, id, omit(data, 'channel'));
    }
}
