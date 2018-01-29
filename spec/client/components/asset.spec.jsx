import React from 'react'; // eslint-disable-line no-unused-vars
import Dropzone from 'react-dropzone';
import Asset from 'hippo/components/asset';
import { TestImage } from '../test-models';

describe('Asset Component', () => {
    it('renders', () => {
        const image = new TestImage();
        const asset = mount(<Asset model={image} name="asset" />);
        expect(asset).toHaveRendered(Dropzone);
    });
});
