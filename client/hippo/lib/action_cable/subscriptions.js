/* eslint-disable */
import ActionCable from './cable';

// Collection class for creating (and internally managing) channel subscriptions. The only method intended to be triggered by the user
// us ActionCable.Subscriptions#create, and it should be called through the consumer like so:

//   @App = {}
//   App.cable = ActionCable.createConsumer "ws://example.com/accounts/1"
//   App.appearance = App.cable.subscriptions.create "AppearanceChannel"

// For more details on how you'd configure an actual channel subscription, see ActionCable.Subscription.
ActionCable.Subscriptions = class Subscriptions {
    constructor(consumer) {
        this.consumer = consumer;
        this.subscriptions = [];
    }

    create(channelName, mixin) {
        var channel, params, subscription;
        channel = channelName;
        params = typeof channel === "object" ? channel : {channel};
        subscription = new ActionCable.Subscription(this.consumer, params, mixin);
        return this.add(subscription);
    }

    // Private
    add(subscription) {
        this.subscriptions.push(subscription);
        this.consumer.ensureActiveConnection();
        this.notify(subscription, "initialized");
        this.sendCommand(subscription, "subscribe");
        return subscription;
    }

    remove(subscription) {
        this.forget(subscription);
        if (!this.findAll(subscription.identifier).length) {
            this.sendCommand(subscription, "unsubscribe");
        }
        return subscription;
    }

    reject(identifier) {
        var i, len, ref, results, subscription;
        ref = this.findAll(identifier);
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
            subscription = ref[i];
            this.forget(subscription);
            this.notify(subscription, "rejected");
            results.push(subscription);
        }
        return results;
    }

    forget(subscription) {
        var s;
        this.subscriptions = (function() {
            var i, len, ref, results;
            ref = this.subscriptions;
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
                s = ref[i];
                if (s !== subscription) {
                    results.push(s);
                }
            }
            return results;
        }).call(this);
        return subscription;
    }

    findAll(identifier) {
        var i, len, ref, results, s;
        ref = this.subscriptions;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
            s = ref[i];
            if (s.identifier === identifier) {
                results.push(s);
            }
        }
        return results;
    }

    reload() {
        var i, len, ref, results, subscription;
        ref = this.subscriptions;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
            subscription = ref[i];
            results.push(this.sendCommand(subscription, "subscribe"));
        }
        return results;
    }

    notifyAll(callbackName, ...args) {
        var i, len, ref, results, subscription;
        ref = this.subscriptions;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
            subscription = ref[i];
            results.push(this.notify(subscription, callbackName, ...args));
        }
        return results;
    }

    notify(subscription, callbackName, ...args) {
        var i, len, results, subscriptions;
        if (typeof subscription === "string") {
            subscriptions = this.findAll(subscription);
        } else {
            subscriptions = [subscription];
        }
        results = [];
        for (i = 0, len = subscriptions.length; i < len; i++) {
            subscription = subscriptions[i];
            results.push(typeof subscription[callbackName] === "function" ? subscription[callbackName](...args) : void 0);
        }
        return results;
    }

    sendCommand(subscription, command) {
        var identifier;
        ({identifier} = subscription);
        return this.consumer.send({command, identifier});
  }

};
