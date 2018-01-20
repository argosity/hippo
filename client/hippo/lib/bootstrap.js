// this file's imports should be kept as small as possible, it'll be typical used
// to bootstrap a remote lib

// it also will be loaded without polyfills, so only es3

import whenDomReady from './when-dom-ready';

export default class Bootstrap {

    constructor(options = {}) {
        this.options = options;
        this.callbacks = { onReady: [] };
        if (this.options.onReady) { this.onReady(this.options.onReady); }

        whenDomReady(() => this.readLoadUrl());
    }

    tagMatches(tag) {
        return !!tag.src.match(this.options.srcTag);
    }

    readLoadUrl() {
        const tags = document.querySelectorAll('script');
        for (let i = 0; i < tags.length; i += 1) {
            const tag = tags[i];
            if (this.tagMatches(tag)) {
                this.signalDone(tag.src.replace(this.options.srcTag, ''), tag.dataset);
                return;
            }
        }
        // eslint-disable-next-line no-console
        console.error('Unable to find script tag that Stockor was loaded from');
    }

    onReady(cb) {
        return this.callbacks.onReady.push(cb);
    }

    signalDone(host, data) {
        this.callbacks.onReady.map(cb => cb(host, data));
    }

}
