import React from 'react';

import { Col } from 'react-flexbox-grid';
import Asset from 'lanes/components/asset';

import { TestImage } from '../test-models';
import { Snapshot } from '../test-utils';

describe("Asset Component", () => {
    it('renders and matches snapshot', () => {
        const image = new TestImage();
        const asset = mount(<Asset model={image} property="asset" />);
        expect(asset).toHaveRendered('Dropzone');
        expect(Snapshot(<Asset model={image} property="asset" />)).toMatchSnapshot();
    });
});
