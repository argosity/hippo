import React        from 'react'; // eslint-disable-line no-unused-vars
import ReactDOM     from 'react-dom';
import whenDomReady from 'when-dom-ready';
import { delay } from 'lodash';
import { unresolvedAssociations } from 'mobx-decorated-models';

import { onBoot } from './models/pub_sub';
import './extensions/hippo';
import Tenant from './models/tenant';

import Workspace from './workspace';

let Root;
//
// function renderer(Body) {
// }
//
// if (module.hot) {
//     module.hot.accept('./workspace', () => {
//         //const WSNext = require('hippo/workspace').default; // eslint-disable-line global-require
//         return renderer(Workspace);
//     });
// }

whenDomReady().then(() => {
    if (Root) return;
    /* global document: true  */
    Root = document.getElementById('hippo-root');

    Tenant.bootstrap(
        JSON.parse(document.getElementById('bootstrap-data').innerHTML),
    );
    /* global document: false */
//    renderer(Workspace);
    ReactDOM.render(<Workspace />, Root);

    unresolvedAssociations().forEach(({ model, property }) => {
        // eslint-disable-next-line no-console
        console.warn(`The model for ${model.identifiedBy}(${property}) cannot be found`);
    });

    const loading = document.querySelector('.hippo-app-loading');
    if (loading) {
        loading.classList.add('complete');
        delay(() => {
            onBoot();
            loading.parentNode.removeChild(loading);
        }, 400);
    }
});
