import FileRepository from '@ckeditor/ckeditor5-upload/src/filerepository';
import ObservableMixin from '@ckeditor/ckeditor5-utils/src/observablemixin';
import mix from '@ckeditor/ckeditor5-utils/src/mix';

class Adapter {

    constructor(loader, t) {
        this.loader = loader;
        this.t = t;
    }

    get assets() {
        return this.t.config.get('assets');
    }

    get asset() {
        return this.assets.find(
            asset => asset.metadata && asset.metadata.nodeId === this.loader.id,
        );
    }

    upload() {
        if (!this.asset) {
            this.assets.push({ metadata: { nodeId: this.loader.id } });
            if (!this.asset) {
                return Promise.reject(new Error('unable to create asset model'));
            }
        }
        return new Promise((resolve, reject) => {
            this.asset.setFile(this.loader.file).then(() => {
                this.asset.save().then(() => {
                    resolve({ default: this.asset.urlFor() });
                });
            }).catch(reject);
        });
    }

}


export default class HippoUploadAdapter {

    static get requires() {
        return [FileRepository];
    }

    static get pluginName() {
        return 'HippoUploadAdapter';
    }

    constructor(editor) {
        this.editor = editor;
    }

    init() {
        this.editor.plugins.get(FileRepository).createAdapter = loader =>
            new Adapter(loader, this.editor);
    }

    destroy() {
        this.stopListening();
    }

}

mix(Plugin, ObservableMixin);
