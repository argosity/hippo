import React from 'react';
import SnapShot   from 'react-test-renderer';
import Screens from 'hippo/screens';
import ScreenDefinitions from 'hippo/screen-definitions';
import TestWrapper from './wrapper';

export { Screens, ScreenDefinitions };

export function getScreenInstance(screenId) {
    return Screens.all.get(screenId).display();
}

export function Snapshot(el) {
    const snapshot = SnapShot.create(React.createElement(TestWrapper, {}, el));
    return snapshot.toJSON();
}
