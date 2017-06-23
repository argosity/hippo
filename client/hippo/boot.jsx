import React        from 'react'; // eslint-disable-line no-unused-vars
import ReactDOM     from 'react-dom';
import whenDomReady from 'when-dom-ready';
import { delay } from 'lodash';
import { AppContainer } from 'react-hot-loader';
import { onBoot } from './models/pub_sub';
import './extensions/hippo';

const Workspace = require('hippo/workspace').default;

let Root;

function renderer(Body) {
    ReactDOM.render(<AppContainer><Body /></AppContainer>, Root);
}

if (module.hot) {
    module.hot.accept('hippo/workspace', () => {
        const WSNext = require('hippo/workspace').default; // eslint-disable-line global-require
        renderer(WSNext);
    });
}

whenDomReady().then(() => {
    if (Root) return;
    /* global document: true  */
    Root = document.getElementById('hippo-root');
    /* global document: false */
    renderer(Workspace);
    const loading = document.querySelector('.loading');
    if (loading) {
        loading.classList.add('complete');
        delay(() => {
            onBoot();
            loading.parentNode.removeChild(loading);

        }, 400);

    }
});
