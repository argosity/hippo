/* global jest */

import React from 'react';
import SnapShot   from 'react-test-renderer';

import Screens from 'hippo/screens';
import ScreenDefinitions from 'hippo/screen-definitions';

export { Screens, ScreenDefinitions };

export function getScreenInstance(screenId) {
    return Screens.all.get(screenId).display();
}


class TestRouter {

    constructor() {
        Object.assign(this, {
            isActive:   jest.fn(),
            push:       jest.fn(),
            replace:    jest.fn(),
            createPath: jest.fn(),
            listen:     jest.fn(() => {
                this.unlisten = jest.fn();
                return this.unlisten;
            }),
        });
    }

}

function makeContext() {
    return {
        router: new TestRouter(),
    };
}

function childContextTypes() {
    return {
        router: React.PropTypes.object,
    };
}

export class Context {

    constructor() {
        this.childContextTypes = childContextTypes();
        this.context = makeContext();
    }

}

export function Snapshot(el) {
    class Wrapper extends React.Component {

        static childContextTypes = childContextTypes();

        getChildContext() {
            return this._childContext || (this._childContext = makeContext());
        }

        render() {
            return el;
        }

    }
    const snapshot = SnapShot.create(React.createElement(Wrapper, {}, el));
    return snapshot.toJSON();
}
