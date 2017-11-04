/* eslint-disable */

const ActionCable = {

  INTERNAL: {},
  WebSocket: window.WebSocket,
  logger: window.console,
  createConsumer: function(url) {
    var ref;
    if (url == null) {
      url = (ref = this.getConfig("url")) != null ? ref : this.INTERNAL.default_mount_path;
    }
    return new ActionCable.Consumer(this.createWebSocketURL(url));
  },
  getConfig: function(name) {
    var element;
    element = document.head.querySelector(`meta[name='action-cable-${name}']`);
    return element != null ? element.getAttribute("content") : void 0;
  },
  createWebSocketURL: function(url) {
    var a;
    if (url && !/^wss?:/i.test(url)) {
      a = document.createElement("a");
      a.href = url;
      // Fix populating Location properties in IE. Otherwise, protocol will be blank.
      a.href = a.href;
      a.protocol = a.protocol.replace("http", "ws");
      return a.href;
    } else {
      return url;
    }
  },
  startDebugging: function() {
    return this.debugging = true;
  },
  stopDebugging: function() {
    return this.debugging = null;
  },
  log: function(...messages) {
    if (this.debugging) {
      messages.push(Date.now());
      return this.logger.log("[ActionCable]", ...messages);
    }
  }
};

export default ActionCable;
