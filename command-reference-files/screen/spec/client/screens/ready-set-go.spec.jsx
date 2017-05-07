import { React, Snapshot, getScreenInstance } from 'hippo/testing/index';
import ReadySetGo from 'appy-app/screens/ready-set-go';

const screenInstance = getScreenInstance('ready-set-go');

describe('Screen ReadySetGo', () => {
    it('renders and matches snapshot', () => {
        const screen = shallow(<ReadySetGo screen={screenInstance} />);
        expect(screen).toHaveRendered('ReadySetGo');
        expect(Snapshot(<ReadySetGo screen={screenInstance} />)).toMatchSnapshot();
    });
});
