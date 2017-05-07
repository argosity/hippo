import React from 'react';

import NetworkActivityOverlay from 'hippo/components/network-activity-overlay';
import { Box } from '../test-models';
import { Snapshot } from 'hippo/testing/screens';

jest.useFakeTimers();

describe('Network Activity Overlay', () => {
    let model;
    beforeEach(() => {
        model = new Box();
    });

    it('renders', () => {
        const activity = mount(<NetworkActivityOverlay model={model} />);
        expect(activity).not.toHaveRendered('.mask');
        model.syncInProgress = { method: 'PUT' };
        expect(activity).toHaveRendered('.mask');
        expect(activity.find('span').text()).toEqual('Saving…');
        jest.runAllTimers();
        expect(activity).not.toHaveRendered('.mask');
    });

    it('matches snapshot', () => {
        model.syncInProgress = { method: 'DELETE' };
        jest.runAllTimers();
        expect(Snapshot(<NetworkActivityOverlay model={model} />)).toMatchSnapshot();
    });
});
