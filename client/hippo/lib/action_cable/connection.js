/* eslint-disable */

import ActionCable from './cable';

  // Encapsulate the cable connection held by the consumer. This is an internal class not intended for direct user manipulation.
var i, message_types, protocols, supportedProtocols, unsupportedProtocol,
  slice = [].slice,
  indexOf = [].indexOf;

protocols = ["actioncable-v1-json", "actioncable-unsupported"];

//({message_types, protocols} = ActionCable.INTERNAL);
message_types = {
    welcome: "welcome",
    ping: "ping",
    confirmation: "confirm_subscription",
    rejection: "reject_subscription",
};

    supportedProtocols = 2 <= protocols.length ? slice.call(protocols, 0, i = protocols.length - 1) : (i = 0, []), unsupportedProtocol = protocols[i++];

ActionCable.Connection = (function() {
  class Connection {
    constructor(consumer) {
      this.open = this.open.bind(this);
      this.consumer = consumer;
      ({subscriptions: this.subscriptions} = this.consumer);
      this.monitor = new ActionCable.ConnectionMonitor(this);
      this.disconnected = true;
    }

    send(data) {
      if (this.isOpen()) {
        this.webSocket.send(JSON.stringify(data));
        return true;
      } else {
        return false;
      }
    }

    open() {
      if (this.isActive()) {
        ActionCable.log(`Attempted to open WebSocket, but existing socket is ${this.getState()}`);
        return false;
      } else {
        ActionCable.log(`Opening WebSocket, current state is ${this.getState()}, subprotocols: ${protocols}`);
        if (this.webSocket != null) {
          this.uninstallEventHandlers();
        }
        this.webSocket = new ActionCable.WebSocket(this.consumer.url, protocols);
        this.installEventHandlers();
        this.monitor.start();
        return true;
      }
    }

    close({allowReconnect} = {
        allowReconnect: true
      }) {
      var ref;
      if (!allowReconnect) {
        this.monitor.stop();
      }
      if (this.isActive()) {
        return (ref = this.webSocket) != null ? ref.close() : void 0;
      }
    }

    reopen() {
      var error;
      ActionCable.log(`Reopening WebSocket, current state is ${this.getState()}`);
      if (this.isActive()) {
        try {
          return this.close();
        } catch (error1) {
          error = error1;
          return ActionCable.log("Failed to reopen WebSocket", error);
        } finally {
          ActionCable.log(`Reopening WebSocket in ${this.constructor.reopenDelay}ms`);
          setTimeout(this.open, this.constructor.reopenDelay);
        }
      } else {
        return this.open();
      }
    }

    getProtocol() {
      var ref;
      return (ref = this.webSocket) != null ? ref.protocol : void 0;
    }

    isOpen() {
      return this.isState("open");
    }

    isActive() {
      return this.isState("open", "connecting");
    }

    // Private
    isProtocolSupported() {
      var ref;
      return ref = this.getProtocol(), indexOf.call(supportedProtocols, ref) >= 0;
    }

    isState(...states) {
      var ref;
      return ref = this.getState(), indexOf.call(states, ref) >= 0;
    }

    getState() {
      var ref, state, value;
      for (state in WebSocket) {
        value = WebSocket[state];
        if (value === ((ref = this.webSocket) != null ? ref.readyState : void 0)) {
          return state.toLowerCase();
        }
      }
      return null;
    }

    installEventHandlers() {
      var eventName, handler;
      for (eventName in this.events) {
        handler = this.events[eventName].bind(this);
        this.webSocket[`on${eventName}`] = handler;
      }
    }

    uninstallEventHandlers() {
      var eventName;
      for (eventName in this.events) {
        this.webSocket[`on${eventName}`] = function() {};
      }
    }

  };

  Connection.reopenDelay = 500;

  Connection.prototype.events = {
    message: function(event) {
      var identifier, message, type;
      if (!this.isProtocolSupported()) {
        return;
      }


        ({identifier, message, type} = JSON.parse(event.data));
      switch (type) {
        case message_types.welcome:
          this.monitor.recordConnect();
          return this.subscriptions.reload();
        case message_types.ping:
          return this.monitor.recordPing();
        case message_types.confirmation:
          return this.subscriptions.notify(identifier, "connected");
        case message_types.rejection:
          return this.subscriptions.reject(identifier);
        default:
          return this.subscriptions.notify(identifier, "received", message);
      }
    },
    open: function() {
      ActionCable.log(`WebSocket onopen event, using '${this.getProtocol()}' subprotocol`);
      this.disconnected = false;
      if (!this.isProtocolSupported()) {
        ActionCable.log("Protocol is unsupported. Stopping monitor and disconnecting.");
        return this.close({
          allowReconnect: false
        });
      }
    },
    close: function(event) {
      ActionCable.log("WebSocket onclose event");
      if (this.disconnected) {
        return;
      }
      this.disconnected = true;
      this.monitor.recordDisconnect();
      return this.subscriptions.notifyAll("disconnected", {
        willAttemptReconnect: this.monitor.isRunning()
      });
    },
    error: function() {
      return ActionCable.log("WebSocket onerror event");
    }
  };

  return Connection;

})();
