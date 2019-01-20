/* eslint no-param-reassign: 0 */
import qs from 'qs';
import 'whatwg-fetch'; // fetch polyfill
import { isEmpty } from 'lodash';
import Config     from '../config';

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

// function invokeWhenComplete(json, progress) {
//     const calls = sortBy(progress._whenComplete, 'precendence');
//     return calls.reduce((p, { fn }) => p.then(() => {
//         const ret = fn(json);
//         return (ret && ret.then) ? ret : Promise.resolve();
//     }), Promise.resolve());
// }

export default
function sync(urlPrefix, defaultOptions = {}) {
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
//
// const peformMobxyRequest = action('SyncforModel', (mobxObj, options = {}) => {
//     const progress = new SyncProgess(options);
//     mobxObj.syncInProgress = progress
//     return perform(options.url || mobxObj.syncUrl, options)
//         .then(action('syncSuccessHandler', (json) => {
//             mobxObj.syncData = json.data;
//             mobxObj.errors = json.errors;
//             mobxObj.lastServerMessage = json.message;
//
//             // sometimes the polyfill (or fetch iteself) sets a `:success` property?
//             if (false === json[':success']) { merge(mobxObj, { errors: { fetch: json[':message'] } }); }
//             return json;
//         }))
//         .then(json => mobxObj.syncInProgress.signalComplete(json))
//
//         .catch(action('syncErrorHandler', (e) => {
//             logger.warn(e);
//             mobxObj.errors.network = e;
//             mobxObj.signalComplete({});
// //            mobxObj.setLastServerMessage.set e.toString();
//             return mobxObj;
//         }));
// });
//
// function forCollection(collection, options = {}) {
//     return peformMobxyRequest(collection, options);
// }
//
// const forModel = action('SyncforModel', (model, options = {}) => {
//     const httpAction = options.action || (model.isNew ? 'create' : 'update');
//     const requestOptions = merge({
//         method: methodMap[httpAction],
//     }, options);
//
//     if (isUpdate(requestOptions.method)) {
//         requestOptions.body = JSON.stringify(options.json || model.syncData);
//     }
//
//     return peformMobxyRequest(model, requestOptions);
// });
//
// //export default sync;
