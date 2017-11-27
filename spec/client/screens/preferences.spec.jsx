import { React, Snapshot, getScreenInstance } from 'hippo/testing/index'; // eslint-disable-line
import Preferences from 'hippo/screens/preferences';

const screenInstance = getScreenInstance('preferences');

describe('Screen Preferences', () => {
    it('renders and matches snapshot', () => {
        const screen = shallow(<Preferences screen={screenInstance} />);
        expect(screen).toHaveRendered('Preferences');
        expect(Snapshot(<Preferences screen={screenInstance} />)).toMatchSnapshot();
    });
});
