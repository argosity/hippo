/*

Jasmine-Ajax : a set of helpers for testing AJAX requests under the Jasmine
BDD framework for JavaScript.

http://github.com/pivotal/jasmine-ajax

Jasmine Home page: http://pivotal.github.com/jasmine

Copyright (c) 2008-2013 Pivotal Labs

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

getJasmineRequireObj().ajax = function(jRequire) {
    const $ajax = {};

    $ajax.RequestStub = jRequire.AjaxRequestStub();
    $ajax.RequestTracker = jRequire.AjaxRequestTracker();
    $ajax.StubTracker = jRequire.AjaxStubTracker();
    $ajax.ParamParser = jRequire.AjaxParamParser();
    $ajax.fakeRequest = jRequire.AjaxFakeRequest();
    $ajax.MockAjax = jRequire.MockAjax($ajax);

    return $ajax.MockAjax;
};

getJasmineRequireObj().AjaxFakeRequest = function() {
    function extend(destination, source, propertiesToSkip) {
        propertiesToSkip = propertiesToSkip || [];
        for (const property in source) {
            if (!arrayContains(propertiesToSkip, property)) {
                destination[property] = source[property];
            }
        }
        return destination;
    }

    function arrayContains(arr, item) {
        for (let i = 0; i < arr.length; i++) {
            if (arr[i] === item) {
                return true;
            }
        }
        return false;
    }

    function wrapProgressEvent(xhr, eventName) {
        return function() {
            if (xhr[eventName]) {
                xhr[eventName]();
            }
        };
    }

    function initializeEvents(xhr) {
        return {
            loadstart: wrapProgressEvent(xhr, 'onloadstart'),
            load: wrapProgressEvent(xhr, 'onload'),
            loadend: wrapProgressEvent(xhr, 'onloadend'),
            progress: wrapProgressEvent(xhr, 'onprogress'),
            error: wrapProgressEvent(xhr, 'onerror'),
            abort: wrapProgressEvent(xhr, 'onabort'),
            timeout: wrapProgressEvent(xhr, 'ontimeout'),
        };
    }

    function unconvertibleResponseTypeMessage(type) {
        const msg = [
            "Can't build XHR.response for XHR.responseType of '",
            type,
            "'.",
            'XHR.response must be explicitly stubbed',
        ];
        return msg.join(' ');
    }

    function fakeRequest(global, requestTracker, stubTracker, paramParser) {
        function FakeXMLHttpRequest() {
            requestTracker.track(this);
            this.events = initializeEvents(this);
            this.requestHeaders = {};
            this.overriddenMimeType = null;
        }

        function findHeader(name, headers) {
            name = name.toLowerCase();
            for (const header in headers) {
                if (header.toLowerCase() === name) {
                    return headers[header];
                }
            }
        }

        function normalizeHeaders(rawHeaders, contentType) {
            let headers = [];

            if (rawHeaders) {
                if (rawHeaders instanceof Array) {
                    headers = rawHeaders;
                } else {
                    for (const headerName in rawHeaders) {
                        if (rawHeaders.hasOwnProperty(headerName)) {
                            headers.push({ name: headerName, value: rawHeaders[headerName] });
                        }
                    }
                }
            } else {
                headers.push({ name: 'Content-Type', value: contentType || 'application/json' });
            }

            return headers;
        }

        function parseXml(xmlText, contentType) {
            if (global.DOMParser) {
                return (new global.DOMParser()).parseFromString(xmlText, 'text/xml');
            }
            const xml = new global.ActiveXObject('Microsoft.XMLDOM');
            xml.async = 'false';
            xml.loadXML(xmlText);
            return xml;
        }

        const xmlParsables = ['text/xml', 'application/xml'];

        function getResponseXml(responseText, contentType) {
            if (arrayContains(xmlParsables, contentType.toLowerCase())) {
                return parseXml(responseText, contentType);
            } else if (contentType.match(/\+xml$/)) {
                return parseXml(responseText, 'text/xml');
            }
            return null;
        }

        const iePropertiesThatCannotBeCopied = ['responseBody', 'responseText', 'responseXML', 'status', 'statusText', 'responseTimeout'];
        extend(FakeXMLHttpRequest.prototype, new global.XMLHttpRequest(), iePropertiesThatCannotBeCopied);
        extend(FakeXMLHttpRequest.prototype, {
            open() {
                this.method = arguments[0];
                this.url = arguments[1];
                this.username = arguments[3];
                this.password = arguments[4];
                this.readyState = 1;
                this.onreadystatechange();
            },

            setRequestHeader(header, value) {
                if (this.requestHeaders.hasOwnProperty(header)) {
                    this.requestHeaders[header] = [this.requestHeaders[header], value].join(', ');
                } else {
                    this.requestHeaders[header] = value;
                }
            },

            overrideMimeType(mime) {
                this.overriddenMimeType = mime;
            },

            abort() {
                this.readyState = 0;
                this.status = 0;
                this.statusText = 'abort';
                this.onreadystatechange();
                this.events.progress();
                this.events.abort();
                this.events.loadend();
            },

            readyState: 0,

            onloadstart: null,
            onprogress: null,
            onabort: null,
            onerror: null,
            onload: null,
            ontimeout: null,
            onloadend: null,

            onreadystatechange(isTimeout) {
            },

            addEventListener(event, callback) {
                let existingCallback = this.events[event],
                    self = this;

                this.events[event] = function() {
                    callback.apply(self);
                    existingCallback();
                };
            },

            status: null,

            send(data) {
                this.params = data;
                this.readyState = 2;
                this.events.loadstart();
                this.onreadystatechange();

                const stub = stubTracker.findStub(this.url, data, this.method);
                if (stub) {
                    this.respondWith(stub);
                }
            },

            contentType() {
                return findHeader('content-type', this.requestHeaders);
            },

            data() {
                if (!this.params) {
                    return {};
                }

                return paramParser.findParser(this).parse(this.params);
            },

            getResponseHeader(name) {
                name = name.toLowerCase();
                let resultHeader;
                for (let i = 0; i < this.responseHeaders.length; i++) {
                    const header = this.responseHeaders[i];
                    if (name === header.name.toLowerCase()) {
                        if (resultHeader) {
                            resultHeader = [resultHeader, header.value].join(', ');
                        } else {
                            resultHeader = header.value;
                        }
                    }
                }
                return resultHeader;
            },

            getAllResponseHeaders() {
                const responseHeaders = [];
                for (let i = 0; i < this.responseHeaders.length; i++) {
                    responseHeaders.push(`${this.responseHeaders[i].name}: ${
            this.responseHeaders[i].value}`);
                }
                return `${responseHeaders.join('\r\n')}\r\n`;
            },

            responseText: null,
            response: null,
            responseType: null,

            responseValue() {
                switch (this.responseType) {
                case null:
                case '':
                case 'text':
                    return 3 <= this.readyState ? this.responseText : '';
                case 'json':
                    return JSON.parse(this.responseText);
                case 'arraybuffer':
                    throw unconvertibleResponseTypeMessage('arraybuffer');
                case 'blob':
                    throw unconvertibleResponseTypeMessage('blob');
                case 'document':
                    return this.responseXML;
                }
            },


            respondWith(response) {
                if (4 === this.readyState) {
                    throw new Error('FakeXMLHttpRequest already completed');
                }
                this.status = response.status;
                this.statusText = response.statusText || '';
                this.responseText = response.responseText || '';
                this.responseType = response.responseType || '';
                this.readyState = 4;
                this.responseHeaders = normalizeHeaders(response.responseHeaders, response.contentType);
                this.responseXML = getResponseXml(response.responseText, this.getResponseHeader('content-type') || '');
                if (this.responseXML) {
                    this.responseType = 'document';
                }

                if ('response' in response) {
                    this.response = response.response;
                } else {
                    this.response = this.responseValue();
                }

                this.onreadystatechange();
                this.events.progress();
                this.events.load();
                this.events.loadend();
            },

            responseTimeout() {
                if (4 === this.readyState) {
                    throw new Error('FakeXMLHttpRequest already completed');
                }
                this.readyState = 4;
                jasmine.clock().tick(30000);
                this.onreadystatechange('timeout');
                this.events.progress();
                this.events.timeout();
                this.events.loadend();
            },

            responseError() {
                if (4 === this.readyState) {
                    throw new Error('FakeXMLHttpRequest already completed');
                }
                this.readyState = 4;
                this.onreadystatechange();
                this.events.progress();
                this.events.error();
                this.events.loadend();
            },
        });

        return FakeXMLHttpRequest;
    }

    return fakeRequest;
};

getJasmineRequireObj().MockAjax = function($ajax) {
    function MockAjax(global) {
        let requestTracker = new $ajax.RequestTracker(),
            stubTracker = new $ajax.StubTracker(),
            paramParser = new $ajax.ParamParser(),
            realAjaxFunction = global.XMLHttpRequest,
            mockAjaxFunction = $ajax.fakeRequest(global, requestTracker, stubTracker, paramParser);

        this.install = function() {
            global.XMLHttpRequest = mockAjaxFunction;
        };

        this.uninstall = function() {
            global.XMLHttpRequest = realAjaxFunction;

            this.stubs.reset();
            this.requests.reset();
            paramParser.reset();
        };

        this.stubRequest = function(url, data, method) {
            const stub = new $ajax.RequestStub(url, data, method);
            stubTracker.addStub(stub);
            return stub;
        };

        this.withMock = function(closure) {
            this.install();
            try {
                closure();
            } finally {
                this.uninstall();
            }
        };

        this.addCustomParamParser = function(parser) {
            paramParser.add(parser);
        };

        this.requests = requestTracker;
        this.stubs = stubTracker;
    }

    return MockAjax;
};

getJasmineRequireObj().AjaxParamParser = function() {
    function ParamParser() {
        const defaults = [
            {
                test(xhr) {
                    return (/^application\/json/).test(xhr.contentType());
                },
                parse: function jsonParser(paramString) {
                    return JSON.parse(paramString);
                },
            },
            {
                test(xhr) {
                    return true;
                },
                parse: function naiveParser(paramString) {
                    const data = {};
                    const params = paramString.split('&');

                    for (let i = 0; i < params.length; ++i) {
                        const kv = params[i].replace(/\+/g, ' ').split('=');
                        const key = decodeURIComponent(kv[0]);
                        data[key] = data[key] || [];
                        data[key].push(decodeURIComponent(kv[1]));
                    }
                    return data;
                },
            },
        ];
        let paramParsers = [];

        this.add = function(parser) {
            paramParsers.unshift(parser);
        };

        this.findParser = function(xhr) {
            for (const i in paramParsers) {
                const parser = paramParsers[i];
                if (parser.test(xhr)) {
                    return parser;
                }
            }
        };

        this.reset = function() {
            paramParsers = [];
            for (const i in defaults) {
                paramParsers.push(defaults[i]);
            }
        };

        this.reset();
    }

    return ParamParser;
};

getJasmineRequireObj().AjaxRequestStub = function() {
    function RequestStub(url, stubData, method) {
        const normalizeQuery = function(query) {
            return query ? query.split('&').sort().join('&') : undefined;
        };

        if (url instanceof RegExp) {
            this.url = url;
            this.query = undefined;
        } else {
            const split = url.split('?');
            this.url = split[0];
            this.query = 1 < split.length ? normalizeQuery(split[1]) : undefined;
        }

        this.data = normalizeQuery(stubData);
        this.method = method;

        this.andReturn = function(options) {
            this.status = options.status || 200;

            this.contentType = options.contentType;
            this.response = options.response;
            this.responseText = options.responseText;
        };

        this.matches = function(fullUrl, data, method) {
            let matches = false;
            fullUrl = fullUrl.toString();
            if (this.url instanceof RegExp) {
                matches = this.url.test(fullUrl);
            } else {
                let urlSplit = fullUrl.split('?'),
                    url = urlSplit[0],
                    query = urlSplit[1];
                matches = this.url === url && this.query === normalizeQuery(query);
            }
            return matches && (!this.data || this.data === normalizeQuery(data)) && (!this.method || this.method === method);
        };
    }

    return RequestStub;
};

getJasmineRequireObj().AjaxRequestTracker = function() {
    function RequestTracker() {
        let requests = [];

        this.track = function(request) {
            requests.push(request);
        };

        this.first = function() {
            return requests[0];
        };

        this.count = function() {
            return requests.length;
        };

        this.reset = function() {
            requests = [];
        };

        this.mostRecent = function() {
            return requests[requests.length - 1];
        };

        this.at = function(index) {
            return requests[index];
        };

        this.filter = function(url_to_match) {
            const matching_requests = [];

            for (let i = 0; i < requests.length; i++) {
                if (url_to_match instanceof RegExp &&
            url_to_match.test(requests[i].url)) {
                    matching_requests.push(requests[i]);
                } else if (url_to_match instanceof Function &&
            url_to_match(requests[i])) {
                    matching_requests.push(requests[i]);
                } else if (requests[i].url === url_to_match) {
                    matching_requests.push(requests[i]);
                }
            }

            return matching_requests;
        };
    }

    return RequestTracker;
};

getJasmineRequireObj().AjaxStubTracker = function() {
    function StubTracker() {
        let stubs = [];

        this.addStub = function(stub) {
            stubs.push(stub);
        };

        this.reset = function() {
            stubs = [];
        };

        this.findStub = function(url, data, method) {
            for (let i = stubs.length - 1; 0 <= i; i--) {
                const stub = stubs[i];
                if (stub.matches(url, data, method)) {
                    return stub;
                }
            }
        };
    }

    return StubTracker;
};

(function() {
    let jRequire = getJasmineRequireObj(),
        MockAjax = jRequire.ajax(jRequire);
    if ('undefined' === typeof window && 'object' === typeof exports) {
        exports.MockAjax = MockAjax;
        jasmine.Ajax = new MockAjax(exports);
    } else {
        window.MockAjax = MockAjax;
        jasmine.Ajax = new MockAjax(window);
    }
}());
