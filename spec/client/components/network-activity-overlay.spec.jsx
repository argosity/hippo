import React from 'react'; // eslint-disable-line no-unused-vars
import { Snapshot } from 'hippo/testing/screens';
import NetworkActivityOverlay from 'hippo/components/network-activity-overlay';
import { Box } from '../test-models';

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
