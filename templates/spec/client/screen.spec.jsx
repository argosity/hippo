import { React, Snapshot, getScreenInstance } from 'hippo/testing/index';
import <%= class_name %> from '<%= identifier %>/screens/<%= screen_id %>';

const screenInstance = getScreenInstance('<%= screen_id %>');

describe('Screen <%= class_name %>', () => {
    it('renders and matches snapshot', () => {
        const screen = shallow(<<%= class_name %> screen={screenInstance} />);
        expect(screen).toHaveRendered('<%= class_name %>');
        expect(Snapshot(<<%= class_name %> screen={screenInstance} />)).toMatchSnapshot();
    });
});
