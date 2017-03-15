import React from 'react';
import ReadySetGo from 'appy-app/screens/ready-set-go';
import { Snapshot, getScreenInstance } from 'lanes/testing/screens';

const screenInstance = getScreenInstance('events');

describe('Screen ReadySetGo', () => {
    it('renders and matches snapshot', () => {
        const screen = shallow(<ReadySetGo screen={screenInstance} />);
        expect(screen).toHaveRendered('Screen');
        expect(Snapshot(<ReadySetGo screen={screenInstance} />)).toMatchSnapshot();
    });
});
