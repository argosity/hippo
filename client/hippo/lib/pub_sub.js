import Cable from 'es6-actioncable';

import Config from '../config';

const INSTANCE = null;

export default class Websocket {
    static initialize() {
        const INSTANCE = new Websocket()
        INSTANCE.connect();
    }

    connect() {
        console.log('connecting websocket');

        this.consumer = Cable.createConsumer(
            `${Config.api_host}${Config.api_path}/cable?token=${Config.access_token}`
        );
    }

    getConsumer() {
        if(!this.consumer) {
            this.connect();
        }
        return this.consumer;
    }

    closeConnection() {
        if(this.consumer) {
            Cable.endConsumer(this.consumer);
        }
        delete this.consumer;
    }
}
