import { React, Snapshot, getScreenInstance } from 'hippo/testing/index'; // eslint-disable-line
import Preferences from 'hippo/screens/preferences';

const screenInstance = getScreenInstance('preferences');

describe('Screen Preferences', () => {
    it('renders and matches snapshot', () => {
        expect(Snapshot(<Preferences screen={screenInstance} />)).toMatchSnapshot();
    });
});
