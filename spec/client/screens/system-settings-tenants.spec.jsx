import React from 'react'; // eslint-disable-line no-unused-vars
import Tenant from 'hippo/screens/system-settings/tenant';

describe('SystemSettings Tenants section', () => {
    it('displays warning dialog after update slug', () => {
        expect(1).toEqual(1);
        const t = mount(<Tenant />);
        expect(t).not.toHaveRendered('TenantSlugChange Layer');
        t.find('input[name="name"]').simulate('change', { target: { value: 'NEW' } });
        t.instance().onSave();
        expect(t).toHaveRendered('TenantSlugChange');
        t.unmount();
    });
});
