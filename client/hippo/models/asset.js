import { includes, get, extend } from 'lodash';
import { observe, action } from 'mobx';
import {
    BaseModel, identifiedBy, field, session, identifier, computed,
} from './base';
import Config from '../config';

const IMAGES = [
    'image/png', 'image/jpeg', 'image/gif',
];

const IS_IMAGE = content_type => !!(content_type && (-1 !== IMAGES.indexOf(content_type)));

const UPDATE_METHODS = { POST: true, PUT: true, PATCH: true };

@identifiedBy('hippo/asset')
export default class Asset extends BaseModel {
    @identifier id;
    @field order;

    @session file;

    @session({ type: 'object' }) file_data;
    @session metadata;

    @field({ type: 'object' }) owner;
    @field owner_association_name;

    constructor(props) {
        super(props);
        observe(this, 'owner', this.onOwnerChange, true);
    }

    static get syncUrl() {
        return Config.api_path + Config.assets_path_prefix;
    }

    static urlForSize(data, size) {
        const url = get(data, `${size}.id`);
        return url ? `${Config.api_host}${this.syncUrl}/${url}` : null;
    }

    @action.bound
    onOwnerChange({ newValue: owner }) {
        if (this.ownerSaveDisposer) { this.ownerSaveDisposer(); }
        if (!owner || !owner.isModel) { return; }
        this.ownerSaveDisposer = observe(owner, 'syncInProgress', ({ newValue, oldValue }) => {
            if (this.isDirty &&
                !this.syncInProgress &&
                !oldValue &&
                newValue && newValue.isUpdate
            ) {
                newValue.whenComplete(() => this.save());
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
        return !!(this.file || this.id);
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

    save() {
        if (!this.file) { return Promise.resolve(this); }
        const form = new FormData();

        if (this.id) { form.append('id', this.id); }
        form.append('file', this.file, this.file.name);
        form.append('owner_type', this.owner.constructor.identifiedBy);
        form.append('owner_id', this.owner.identifierFieldValue);
        form.append('owner_association', this.owner_association_name);

        const options = { method: 'POST', body: form, headers: {} };
        if (Config.access_token) {
            options.headers.Authorization = Config.access_token;
        }
        return fetch(`${Config.api_path}${Config.assets_path_prefix}`, options)
            .then(resp => resp.json())
            .then(json => this.set(json.data))
            .then((json) => {
                this.file = undefined;
                return json;
            });
    }
}
