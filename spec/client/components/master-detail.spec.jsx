import React from 'react';

import { Snapshot } from 'hippo/testing/screens';
import MasterDetail from 'hippo/components/master-detail';

function MasterComp() { return <h1>Hi, i am master</h1>; }
function DetailComp() { return <h1>Hi, i am detail</h1>; }

describe('Master Detail Component', () => {
    it('renders and matches snapshot', () => {
        expect(Snapshot(
            <MasterDetail
                master={<MasterComp />}
                detail={<DetailComp />}
            />)).toMatchSnapshot();
    });

    it('renders and then can add detail', () => {
        const md = shallow(<MasterDetail master={<MasterComp />} />);
        expect(md).not.toHaveRendered('.has-detail');
        md.setProps({ detail: <DetailComp /> });
        expect(md).toHaveRendered('.has-detail');
    });
});
