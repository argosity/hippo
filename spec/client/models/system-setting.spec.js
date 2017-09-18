import SystemSettings from 'hippo/models/system-setting';
import Asset from 'hippo/models/asset';

jest.mock('hippo/config');

const TEST_SETTINGS = {
    id: 1,
    logo: { file_data: { foo: 'bar' } },
    settings: { hippo: { smtp: { login: 'test', server: 'test.test.test', password: 'test' } } },
};

describe('SystemSettings Model', () => {
    it('has an asset', () => {
        const ss = new SystemSettings();
        ss.logo = TEST_SETTINGS.logo;
        expect(ss.logo).toBeInstanceOf(Asset);
        expect(ss.logo.file_data.foo).toEqual('bar');
        ss.logo = { };
        expect(ss.logo).toBeInstanceOf(Asset);
    });
});
