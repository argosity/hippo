import React from 'react'; // eslint-disable-line no-unused-vars
import TZ from 'hippo/components/time-zone-select';
import { Snapshot } from 'hippo/testing/screens';


describe('TimeZone Component', () => {
    it('matches snapshot', () => {
        const oc = jest.fn();
        expect(Snapshot(<TZ onChange={oc} value="America/Chicago" />)).toMatchSnapshot();
    });
});
