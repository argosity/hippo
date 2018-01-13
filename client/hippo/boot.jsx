import React        from 'react'; // eslint-disable-line no-unused-vars
import ReactDOM     from 'react-dom';
import whenDomReady from './lib/when-dom-ready';
import { delay } from 'lodash';
import { unresolvedAssociations } from 'mobx-decorated-models';

import { onBoot } from './models/pub_sub';
import './extensions/hippo';
import Tenant from './models/tenant';

import Workspace from './workspace';

let Root;

whenDomReady(() => {
    if (Root) return;
    /* global document: true  */
    Root = document.getElementById('hippo-root');

    Tenant.bootstrap(
        JSON.parse(document.getElementById('bootstrap-data').innerHTML),
    );
    /* global document: false */

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
