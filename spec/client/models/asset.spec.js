import Asset from 'lanes/models/asset';
import LogoJson from '../test-logo.json';

import { TestImage } from '../test-models';

describe('Asset Test', () => {
    let model;
    let file;

    beforeEach(() => {
        model = new TestImage();
        model.asset = new Asset({ owner: model });
        file = new File([''], 'test-image.png', {
            lastModified: 1449505890000,
            lastModifiedDate: new Date(1449505890000),
            name: 'ecp-logo.png',
            size: 44320,
            type: 'image/png',
        });
    });

    it('can use json', () => {
        const image = TestImage.deserialize({ asset: LogoJson });
        expect(image.asset.isImage).toBe(true);
        expect(image.asset.previewUrl)
            .toEqual(`/api/asset/${LogoJson.file_data.thumbnail.id}`);
        expect(image.asset.owner).toBe(image);
        expect(image.asset.owner_association_name).toBe('asset');
    });

    it('can be saved', () => {
        model.asset.file = file;
        expect(model.asset.isDirty).toBe(true);
        model.asset.save();
        expect(fetch).lastCalledWith('/api/asset', expect.objectContaining({
            body: expect.any(FormData),
        }));
    });

    it('attempts to save after owner does', () => {
        model.asset.save = jest.fn();
        expect(model.asset.isDirty).toBe(false);
        model.save();
        expect(model.asset.save).not.toHaveBeenCalled();
        model.asset.file = file;
        expect(model.asset.isDirty).toBe(true);
        model.save();
        expect(model.asset.save).toHaveBeenCalled();
    });
});
