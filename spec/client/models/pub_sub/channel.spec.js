import PubSubChannel from 'hippo/models/pub_sub/channel';

describe('PubSub Channel', () => {
    it('subscribes/unsubscribes', () => {
        const onModelChange = jest.fn();
        const perform = jest.fn();
        const received = jest.fn();
        const chan = new PubSubChannel({
            onModelChange,
            cable: {
                subscriptions: {
                    create: jest.fn(() => ({
                        received,
                        perform,
                    })),
                },
            },
        });
        const spy1 = jest.fn();
        const channel = 'foo/bar/1';
        chan.subscribe(channel, spy1);
        expect(chan.callbacks.get(channel)).toHaveLength(1);
        const msg = { channel: `ps:${channel}` };

        const spy2 = jest.fn();
        chan.subscribe(channel, spy2);

        chan.received(msg);
        expect(spy1).toHaveBeenCalledWith(msg);
        expect(spy2).toHaveBeenCalledWith(msg);

        chan.unsubscribe(channel, spy1);
        chan.received(msg);
        expect(spy1).toHaveBeenCalledTimes(1);
        expect(spy2).toHaveBeenCalledTimes(2);

        expect(onModelChange).not.toHaveBeenCalled();
        chan.unsubscribe(channel, spy2);

        chan.received(msg);
        expect(onModelChange).toHaveBeenCalledWith('foo/bar', '1', {});
        expect(spy1).toHaveBeenCalledTimes(1);
        expect(spy2).toHaveBeenCalledTimes(2);
    });
});
