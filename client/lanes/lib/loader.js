import { logger } from './util';

// https://pie.gd/test/script-link-events/

let doc = window.document;
export function setDocument(newDocument){
    doc = newDocument;
}

const insertBefore = () => {
    const refs = doc.getElementsByTagName('head')[0].childNodes;
    return refs[refs.length - 1];
};

// https://github.com/filamentgroup/loadJS/blob/master/loadJS.js
export function loadJS(src, cb) {
    const ref = insertBefore();
    const script = doc.createElement('script');
    script.src = src;
    script.async = true;
    ref.parentNode.insertBefore(script, ref);
    if (cb && typeof (cb) === 'function') {
        script.onload = ev => cb(script, ev);
    }
    return script;
}


// https://github.com/filamentgroup/loadCSS/blob/master/src/loadCSS.js
export function loadCSS(href, cb) {
    const ss = doc.createElement('link');
    const ref = insertBefore();

    const sheets = doc.styleSheets;
    ss.rel = 'stylesheet';
    ss.href = href;
    ss.media = 'only x';

    // wait until body is defined before injecting link. This ensures a non-blocking load in IE11.
    function ready(cb) {
        if (doc.body) {
            return cb();
        }
        setTimeout(() => {
            ready(cb);
        });
    }
    // Inject link
    // Note: the ternary preserves the existing behavior of "before" argument, but we could choose to change the argument to "after" in a later release and standardize on ref.nextSibling for all refs
    // Note: `insertBefore` is used instead of `appendChild`, for safety re: http://www.paulirish.com/2011/surefire-dom-element-insertion/
    ready(() => {
        ref.parentNode.insertBefore(ss, ref.nextSibling);
    });
    // A method (exposed on return object for external use) that mimics onload by polling document.styleSheets until it includes the new sheet.
    const onloadcssdefined = function (cb) {
        const resolvedHref = ss.href;
        let i = sheets.length;
        while (i--) {
            if (sheets[i].href === resolvedHref) {
                return cb(sheets[i]);
            }
        }
        setTimeout(() => {
            onloadcssdefined(cb);
        });
    };

    function loadCB(ev) {
        if (ss.addEventListener) {
            ss.removeEventListener('load', loadCB);
        }
        ss.media = 'all';
        if (cb && typeof (cb) === 'function') {
            cb(ss, ev);
        }
    }

    // once loaded, set link's media back to `all` so that the stylesheet applies once it loads
    if (ss.addEventListener) {
        ss.addEventListener('load', loadCB);
    } else {
        onloadcssdefined(loadCB);
    }
    return ss;
};
