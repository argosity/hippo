import { includes, get, extend } from 'lodash';
import { observe, action } from 'mobx';
import ModelSync from 'hippo/models/model-sync';
import {
    BaseModel, identifiedBy, field, session, identifier, computed,
} from './base';
import Config from '../config';

const IMAGES = [
    'image/png', 'image/jpeg', 'image/gif',
];

const IS_IMAGE = content_type => !!(content_type && (-1 !== IMAGES.indexOf(content_type)));

const UPDATE_METHODS = { POST: true, PUT: true, PATCH: true };


class AssetSync extends ModelSync {

    destroy() {
        return super.destroy().then(() => {
            if (!this.model.owner) { return; }
            this.model.owner[this.owner_association_name] = null;
        });
    }

    save() {
        if (!this.model.file) { return Promise.resolve(this.model); }
        const form = new FormData();
        if (this.model.id) { form.append('id', this.model.id); }
        form.append('file', this.model.file, this.model.file.name);
        form.append('owner_type', this.model.owner.constructor.identifiedBy);
        form.append('owner_id', this.model.owner.identifierFieldValue);
        form.append('owner_association', this.model.owner_association_name);

        const options = { method: 'POST', body: form, headers: {} };
        if (Config.access_token) {
            options.headers.Authorization = Config.access_token;
        }
        return fetch(`${Config.api_path}${Config.assets_path_prefix}`, options)
            .then(resp => resp.json())
            .then(json => this.model.set(json.data))
            .then((json) => {
                if (this.model.file) {
                    if (this.model.file.preview && window.URL.revokeObjectURL) {
                        window.URL.revokeObjectURL(this.model.file.preview);
                    }
                    this.model.file = undefined;
                }
                return json;
            });
    }

}


export default
@identifiedBy('hippo/asset')
class Asset extends BaseModel {

    @identifier id;

    @field order;

    @session file;

    @session({ type: 'object' }) file_data;

    @session metadata;

    @field({ type: 'object' }) owner;

    @field owner_association_name;

    @ModelSync.lazyCreate sync = new AssetSync({ model: this });

    constructor(props) {
        super(props);
        observe(this, 'owner', this.onOwnerChange, true);
    }

    static get syncUrl() {
        return Config.api_path + Config.assets_path_prefix;
    }

    static urlForSize(data, size) {
        const url = get(data, `${size}.id`);
        return url ? `${Config.asset_host}${this.syncUrl}/${url}` : null;
    }

    @action.bound
    onOwnerChange({ newValue: owner }) {
        if (this.ownerSaveDisposer) { this.ownerSaveDisposer(); }
        if (!owner || !owner.isModel) { return; }
        this.ownerSaveDisposer = observe(owner.sync, 'isSaving', ({ newValue, oldValue }) => {
            if (this.isDirty
                && !this.sync.isSaving
                && !oldValue && newValue
            ) {
                owner.sync.whenComplete('fetch', () => this.sync.save());
            }
        });
    }

    setFile(file) {
        if (file.preview) {
            this.file = file;
            return Promise.resolve(this);
        }
        return new Promise((resolve) => {
            const reader = new FileReader();
            reader.onloadend = (ev) => {
                if ('loadend' === ev.type) {
                    extend(file, { preview: reader.result });
                    this.file = file;
                    resolve(this);
                }
            };
            reader.readAsDataURL(file);
        });
    }

    @computed get isDirty() {
        return Boolean(this.file);
    }

    @computed get exists() {
        return !!(this.file || this.file_data);
    }

    @computed get isImage() {
        return includes(IMAGES, this.mimeType);
    }

    @computed get mimeType() {
        return get(
            this, 'file.type',
            get(this, 'file_data.original.metadata.mime_type'),
        );
    }

    get previewUrl() {
        return get(this, 'file.preview', this.urlFor('thumbnail'));
    }

    urlFor(size = 'original') {
        return this.constructor.urlForSize(this.file_data, size);
    }

}
