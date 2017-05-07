let doc = window.document;
export function setDocument(newDocument) {
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
    if (cb) {
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

    ref.parentNode.insertBefore(ss, ref.nextSibling);

    // A method (exposed on return object for external use) that mimics onload
    // by polling document.styleSheets until it includes the new sheet.
    const onloadcssdefined = (onDefCb) => {
        const resolvedHref = ss.href;
        for (let i = 0; i < sheets.length; i += 1) {
            if (sheets[i].href === resolvedHref) {
                onDefCb(sheets[i]);
                return;
            }
        }
        setTimeout(() => {
            onloadcssdefined(onDefCb);
        });
    };

    function loadCB(ev) {
        if (ss.addEventListener) {
            ss.removeEventListener('load', loadCB);
        }
        ss.media = 'all';
        if (cb) { cb(ss, ev); }
    }

    // once loaded, set link's media back to `all` so that the stylesheet applies once it loads
    if (ss.addEventListener) {
        ss.addEventListener('load', loadCB);
    } else {
        onloadcssdefined(loadCB);
    }
    return ss;
}
