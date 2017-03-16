import UserScreen from 'lanes/screens/user-management';
import Instance  from 'lanes/screens/instance';
import { map, range } from 'lodash';
import Sync from 'lanes/models/sync';

import { getTestScreen } from '../test-models';

jest.mock('lanes/models/sync');

describe('User Management Screen', () => {
    let definition;
    let instance;
    let screen;

    beforeEach(() => {
        definition = getTestScreen();
        instance = new Instance({ definition, isActive: true });
        Sync.setResponseData({
            total: 5,
            success: true,
            data: map(range(0, 5), i =>
                [i, `login-${i}`, `name ${i}`, `email-${i}@test.com`],
            ),
        });
        screen = mount(<UserScreen screen={instance} />);
    });

    it('renders rows', () => {
        expect(screen.find('.ReactVirtualized__Table__row')).toHaveLength(5);
    });

    it('can edit users', () => {
        screen.find('.ReactVirtualized__Table__row').first().find('Button').simulate('click');
        expect(screen).toHaveRendered('EditForm');
        expect(screen).toHaveRendered('input[name="login"][value="login-0"]');
        screen.find('input[name="login"][value="login-0"]').simulate(
            'change', { target: { value: 'bob' } },
        );
        screen.find('button.grommetux-button--primary').simulate('click');
        expect(Sync.forModel).lastCalledWith(expect.objectContaining({
            login: 'bob',
        }), expect.any(Object));
    });
});
