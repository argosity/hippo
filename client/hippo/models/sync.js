/* eslint no-param-reassign: 0 */

import qs from 'qs';
import 'whatwg-fetch'; // fetch polyfill

import { includes, isEmpty, merge, extend, sortBy } from 'lodash';
import { action } from 'mobx';
import Config     from '../config';
import { logger } from '../lib/util';

const methodMap = {
    create:  'POST',
    update:  'PUT',
    patch:   'PATCH',
    destroy: 'DELETE',
    read:    'GET',
};

const paramsMap = {
    fields:  'f',
    with:    'w',
    query:   'q',
    include: 'i',
    order:   'o',
    limit:   'l',
    start:   's',
    format:  'df',
};

function isUpdate(method) {
    return includes(['POST', 'PUT', 'PATCH'], method);
}

class SyncProgess {
    constructor(options) {
        extend(this, options);
        this._whenComplete = [];
    }
    whenComplete(fn, precendence = 1) {
        this._whenComplete.push({ fn, precendence });
    }
    get isFetch() { return 'GET' === this.method; }
    get isCreate() { return 'POST' === this.method; }
    get isUpdate() { return isUpdate(this.method); }
}

function invokeWhenComplete(json, progress) {
    const calls = sortBy(progress._whenComplete, 'precendence');
    return calls.reduce((p, { fn }) => p.then(() => {
        const ret = fn(json);
        return (ret && ret.then) ? ret : Promise.resolve();
    }), Promise.resolve());
}

function perform(urlPrefix, defaultOptions = {}) {
    const query   = {};
    const options = {};

    Object.keys(defaultOptions).forEach((key) => {
        const value = defaultOptions[key];
        if (paramsMap[key]) {
            query[paramsMap[key]] = value;
        } else {
            options[key] = value;
        }
    });

    let url = `${Config.api_host}${urlPrefix}.json`;
    if (!isEmpty(query)) {
        url += `?${qs.stringify(query, { arrayFormat: 'brackets' })}`;
    }
    if (!options.headers) { options.headers = {}; }

    options.headers['Content-Type'] = 'application/json';
    if (Config.access_token) {
        options.headers.Authorization = Config.access_token;
    }
    return fetch(url, options)
        .then(resp => resp.json())
        .then((json) => {
            if (json.token) { Config.access_token = json.token; }
            return json;
        });
}

const peformMobxyRequest = action('SyncforModel', (mobxObj, options = {}) => {
    mobxObj.syncInProgress = new SyncProgess(options);
    return perform(options.url || mobxObj.syncUrl, options)
        .then(action('syncSuccessHandler', (json) => {
            mobxObj.syncData = json.data;
            mobxObj.errors = json.errors;
            mobxObj.lastServerMessage = json.message;

            // sometimes the polyfill (or fetch iteself) sets a `:success` property?
            if (false === json[':success']) { merge(mobxObj, { errors: { fetch: json[':message'] } }); }
            return json;
        }))
        .then(action('whenComplete', json => invokeWhenComplete(json, mobxObj.syncInProgress)))
        .then(action('syncDoneHandler', () => {
            mobxObj.syncInProgress = undefined;
            return mobxObj;
        }))
        .catch(action('syncErrorHandler', (e) => {
            logger.warn(e);
            mobxObj.errors = { network: e };
            mobxObj.syncInProgress = undefined;
            mobxObj.lastServerMessage = e.toString();
            return {};
        }));
});

function forCollection(collection, options = {}) {
    return peformMobxyRequest(collection, options);
}

const forModel = action('SyncforModel', (model, options = {}) => {
    const httpAction = options.action || (model.isNew ? 'create' : 'update');
    const requestOptions = merge({
        method: methodMap[httpAction],
    }, options);

    if (isUpdate(requestOptions.method)) {
        requestOptions.body = JSON.stringify(options.json || model.syncData);
    }
    return peformMobxyRequest(model, requestOptions);
});

export default {
    forModel,
    forCollection,
    perform,
};
