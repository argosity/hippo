import qs from 'qs';
import 'whatwg-fetch'; // fetch polyfill

import { includes, isEmpty, merge, extend, isArray, isObject } from 'lodash';
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
    if (Config.access_token) {
        query.jwt = Config.access_token;
    }
    if (!isEmpty(query)) {
        url += `?${qs.stringify(query, { arrayFormat: 'brackets' })}`;
    }
    if (!options.headers) { options.headers = {}; }

    options.headers['Content-Type'] = 'application/json';
    return fetch(url, options)
        .then(resp => resp.json())
        .then((json) => {
            if (json.token) { Config.access_token = json.token; }
            return json;
        });
}

const peformMobxyRequest = action('SyncforModel', (mobxObj, options = {}) => {
    mobxObj.syncInProgress = options;  // eslint-disable-line no-param-reassign
    return perform(options.url || mobxObj.syncUrl, options)
        .then(action('syncSuccessHandler', (json) => {
            extend(mobxObj, {
                errors:            json.errors,
                syncInProgress:    undefined,
                lastServerMessage: json.message,
            });
            // sometimes the polyfill (or fetch iteself) sets a `:success` property?
            if (false === json[':success']) { merge(mobxObj, { errors: { fetch: json[':message'] } }); }
            return json;
        })).catch(action('syncErrorHandler', (e) => {
            logger.warn(e);
            extend(mobxObj, {
                errors:            { network: e },
                syncInProgress:     undefined,
                lastServerMessage:  e.toString(),
            });
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

    if (includes(['POST', 'PUT', 'PATCH'], requestOptions.method)) {
        requestOptions.body = JSON.stringify(options.json || model.syncData);
    }
    return peformMobxyRequest(model, requestOptions)
        .then(action('syncModelSuccessHandler', (json) => {
            if (isArray(json.data) && json.data.length) {
                model.syncData = json.data[0];  // eslint-disable-line no-param-reassign
            } else if (isObject(json.data)) {
                model.syncData = json.data;  // eslint-disable-line no-param-reassign
            }
            return model;
        }));
});

export default {
    forModel,
    forCollection,
    perform,
};
