import { action, observable, computed } from 'mobx';
import { find, uniqueId, defaults, map, extend, sortBy } from 'lodash';
import { toSentence, humanize } from '../lib/util';
import Sync from './sync';

export default
class SyncAdapter {

    @observable method = ''

    @observable _whenComplete = [];

    @observable lastServerMessage;

    pending = {
        fetch: observable.map(),
    };

    methodMap = {
        create:  'POST',
        update:  'PUT',
        patch:   'PATCH',
        destroy: 'DELETE',
        read:    'GET',
    };

    constructor(options) {
        extend(this, options);
    }

    @action whenComplete(type, fn, precendence = 1) {
        this._whenComplete.push({ fn, type, precendence });
    }

    @action handleReply(type, { data, message, errors }) {
        this.data = data;
        this.lastServerMessage = message;
        this.errors = errors;
        this.signalComplete(type, data);
    }

    @action sync(type, options) {
        const pendingMap = this.pending[type];
        const requestId = uniqueId('req');
        const requestOptions = defaults(options, {
            requestId,
            method: this.methodMap[options.action || 'read'] || 'GET',
        });

        if (-1 !== ['POST', 'PUT', 'PATCH'].indexOf(options.method)) {
            requestOptions.body = JSON.stringify(
                options.json || this.data,
            );
        }

        pendingMap.set(requestId, options);
        return Sync(this.url, requestOptions).then((reply) => {
            this.handleReply(type, reply);
            pendingMap.delete(requestId);
            return this.record;
        });
    }

    @computed get errorMessage() {
        return this.errors ? toSentence(
            map(this.errors, (v, k) => (
                'base' === k ? v : `${humanize(k)} ${v}`
            )),
        ) : '';
    }

    @action signalComplete(json) {
        const calls = sortBy(this._whenComplete, 'precendence');
        return calls.reduce(
            (p, { fn }) => p.then(() => {
                const ret = fn(json);
                return (ret && ret.then) ? ret : Promise.resolve();
            }), Promise.resolve(),
        ).then(() => { this.method = ''; });
    }

    @action fetch(options = {}) {
        return this.sync('fetch', options);
    }

    @computed get isBusy() {
        return Boolean(
            find(
                Object.keys(this.pending),
                k => 0 !== this.pending[k].size,
            ),
        );
    }

    inProgressType(type) {
        return this.pending[type] && this.pending[type].size >= 1;
    }

    @computed get isFetching() {
        return this.pending.fetch.size >= 1;
    }

}
