// this file's imports should be kept as small as possible, it'll be typical used
// to bootstrap a remote lib
import whenDomReady from 'when-dom-ready';

const PENDING  = Symbol('PENDING');
const ERROR    = Symbol('ERROR');
const COMPLETE = Symbol('COMPLETE');

export default class Bootstrap {
    constructor(options = {}) {
        this.options = options;
        this.callbacks = { onReady: [] };
        this.status = PENDING;
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
        this.state = ERROR;
        console.error('Unable to find script tag that Stockor was loaded from'); // eslint-disable-line no-console
    }

    onReady(cb) {
        return this.callbacks.onReady.push(cb);
    }

    signalDone(host, data) {
        this.status = COMPLETE;
        this.callbacks.onReady.map(cb => cb(host, data));
    }
}
