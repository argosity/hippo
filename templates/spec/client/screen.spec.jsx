import React from 'react';
import <%= class_name %> from '<%= identifier %>/screens/<%= screen_id %>';
import { Snapshot, getScreenInstance } from 'lanes/testing/screens';

const screenInstance = getScreenInstance('events');

describe('Screen <%= class_name %>', () => {
    it('renders and matches snapshot', () => {
        const screen = shallow(<<%= class_name %> screen={screenInstance} />);
        expect(screen).toHaveRendered('Screen');
        expect(Snapshot(<<%= class_name %> screen={screenInstance} />)).toMatchSnapshot();
    });
});
