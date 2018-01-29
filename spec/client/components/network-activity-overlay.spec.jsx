import React from 'react'; // eslint-disable-line no-unused-vars
import { Snapshot } from 'hippo/testing/screens';
import T from 'hippo/testing/wrapper';
import NetworkActivityOverlay from 'hippo/components/network-activity-overlay';
import { Box } from '../test-models';

jest.useFakeTimers();

describe('Network Activity Overlay', () => {
    let model;
    beforeEach(() => {
        model = new Box();
    });

    it('renders', () => {
        const activity = mount(<T><NetworkActivityOverlay model={model} /></T>);
        expect(activity).not.toHaveRendered('.mask');
        model.syncInProgress = { method: 'PUT' };
        activity.update();
        expect(activity).toHaveRendered('.mask');
        expect(activity.find('span').text()).toEqual('Saving…');
        jest.runAllTimers();
        activity.update();
        expect(activity).not.toHaveRendered('.mask');
    });

    it('matches snapshot', () => {
        model.syncInProgress = { method: 'DELETE' };
        jest.runAllTimers();
        expect(Snapshot(<NetworkActivityOverlay model={model} />)).toMatchSnapshot();
    });
});
