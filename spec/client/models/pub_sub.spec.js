import { autorun } from 'mobx';
import { onBoot, observePubSub } from 'hippo/models/pub_sub';
import PubSubChannel from 'hippo/models/pub_sub/channel';
import Config from 'hippo/config';
import { Ship, Container } from '../test-models';

jest.mock('hippo/models/pub_sub/channel');
jest.mock('hippo/user', () => ({
    isLoggedIn: true,
}));
jest.mock('hippo/config');

describe('PubSub', () => {
    it('watches and checks in and out', () => {
        Config.api_host = 'testing';
        const ship = new Ship();
        const container = new Container({ id: '2' });
        onBoot();

        expect(PubSubChannel.prototype.subscribe)
            .not.toHaveBeenCalledWith('test/container/2');
        observePubSub(ship, container);
        ship.name = 'test';
        expect(ship.identifierFieldValue).toEqual('test');
        autorun(() => {
            observePubSub(ship);
        });
        expect(PubSubChannel.prototype.subscribe).toHaveBeenCalled();
    });
});
