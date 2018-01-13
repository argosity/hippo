export default function xhr(
    {
        url, method = 'GET', data, headers = {},
    },
    {
        success,
        failure = err => console.warn(err), // eslint-disable-line no-console
    },
) {
    const req = new XMLHttpRequest();
    let body = '';
    req.open(method, url, true);
    if (data) {
        headers['Content-Type'] = 'application/json';
        body = JSON.stringify(data);
    }

    for (const key in headers) {
        // skip loop if the property is from prototype
        if (Object.prototype.hasOwnProperty.call(headers, key)) {
            req.setRequestHeader(key, headers[key]);
        }
    }


    req.onload = function() {
        if (4 === req.readyState && 200 === req.status) {
            success({ response: req.response });
        } else {
            failure(req);
        }
    };

    req.onerror = function() {
        failure(req);
    };

    req.send(body);
}
