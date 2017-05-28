import React from 'react';

import TenantModel from 'hippo/models/tenant';
import Tenant from 'hippo/screens/system-settings/tenant';

describe('SystemSettings Tenants section', () => {
    it('displays warning dialog after update slug', (done) => {
        const t = mount(<Tenant />);
        expect(t).not.toHaveRendered('TenantSlugChange Layer');
        TenantModel.current.slug = 'ONE';
        t.find('input[name="name"]').simulate('change', { target: { value: 'NEW' } });
        t.instance().onSave();
        setTimeout(() => {
            expect(t).toHaveRendered('TenantSlugChange Layer');
            done();
        });
    });
});
