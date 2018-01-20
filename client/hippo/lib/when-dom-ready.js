export default function whenDomReady(cb) {
    const doc = window.document;
    // Resolve now if DOM has already loaded
    // Otherwise wait for DOMContentLoaded
    if (-1 !== ['interactive', 'complete'].indexOf(doc.readyState)) {
        cb();
    } else {
        doc.addEventListener('DOMContentLoaded', cb);
    }
}
