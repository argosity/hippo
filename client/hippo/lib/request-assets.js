import { isArray, pick, isEmpty, keys } from 'lodash';
import { loadCSS, loadJS } from './loader';
import { logger } from './util';

class AssetLoader {
    constructor(urls, cb) {
        let finished = 0;
        const completed = {};
        const onComplete = (url, success, error = false) => {
            finished += 1;
            completed[url] = { success: true === success, error };
            if (finished === urls.length) { cb(completed); }
        };

        Array.from(urls).forEach((baseUrl) => {
            const url = `http://localhost:8889${baseUrl}?${parseInt(Math.random() * 100000, 10)}`;
            if (/.css($|\?)/.test(url)) {
                loadCSS(url, onComplete);
            } else {
                loadJS(url, onComplete);
            }
        });
    }
}

export default function RequestAssets(...urlArgs) {
    const urls = ((1 === urlArgs.length) && isArray(urlArgs[0])) ? urlArgs[0] : urlArgs;
    return new Promise((resolve, reject) =>
        new AssetLoader(urls, (completed) => {
            const failures = pick(completed, status => !status.success);
            if (isEmpty(failures)) {
                return resolve(completed);
            }
            logger.warn(`${keys(failures).join(',')} failed to load`);
            return reject(failures);
        }),
    );
}
