import React        from 'react';
import ReactDOM     from 'react-dom';
import whenDomReady from 'when-dom-ready';

import { AppContainer } from 'react-hot-loader';
import { withAsyncComponents } from 'react-async-component';

import Config from './config';

const Workspace = require('lanes/workspace').default;

let Root;
let App;

function renderer(Body) {
    withAsyncComponents(<AppContainer><Body /></AppContainer>)
        .then((result) => {
            App = result.appWithAsyncComponents;
            ReactDOM.render(App, Root);
        });
}

if (module.hot) {
    module.hot.accept('lanes/workspace', () => {
        const WSNext = require('lanes/workspace').default;
        renderer(WSNext);
    });
}

whenDomReady().then(() => {
    if (Root) return;
    /* global document: true  */
    Root = document.getElementById('lanes-root');
    Config.bootstrap(JSON.parse(document.getElementById('bootstrap-data').innerHTML))
    /* global document: false */
    renderer(Workspace);
});
