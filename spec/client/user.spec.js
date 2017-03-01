jest.mock('lanes/models/sync');
jest.mock('lanes/config');

import { User } from 'lanes/user';
import Config from 'lanes/config';

describe('User Model', () => {
    it('can log in and out', () => {
        const user = new User()//{ id: 42 })
        Config.access_token = '';
        expect(user.isLoggedIn).toBe(false);
        Config.access_token = '93280890';
        expect(user.isLoggedIn).toBe(true);
        user.logout().then(() => {
            expect(Config.access_token).toEqual('');
            expect(user.isLoggedIn).toBe(false);
        });
    });
});
