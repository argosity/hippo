import React from 'react';
import ReactDom from 'react-dom';
import { AppContainer } from 'react-hot-loader';
/* import {
 *     BrowserRouter as Router,
 *     Route,
 *     Link
 * } from 'react-router-dom'*/

// import { Router, Route, match, RouterContext, browserHistory } from 'react-router';

//import createHistory from 'history/createBrowserHistory';

/* function NoMatch() {
 *     return (
 *         <h1>Not Found</h1>
 *     );
 * }*/

import Workspace from '../workspace';

//export default function ViewportRoot(dom){
document.getElementById('root')
    function renderer(S) {
        ReactDom.render(

            <AppContainer>
                <S />
            </AppContainer>

            , dom,
        );
    }

    renderer(Workspace);

    if (module.hot) {
        module.hot.accept('hippo/workspace', () => {
            console.log("RELOADED", arguments)
            renderer(WP)
        });
    }

//}
