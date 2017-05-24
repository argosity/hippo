import { includes, get, isEmpty } from 'lodash';
import qs from 'qs';
import { observe } from 'mobx';
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
    @session file_data;

    @session file;

    @session({ type: 'object' }) file_data;
    @session metadata;

    @field({ type: 'object' }) owner;
    @field owner_association_name;

    constructor(props) {
        super(props);
        observe(this, 'owner', ({ newValue: owner }) => {
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
        }, true);
    }

    @computed get baseUrl() {
        return Config.api_host + Config.api_path + Config.assets_path_prefix;
    }

    @computed get isDirty() {
        return !!this.file;
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

    @computed get previewUrl() {
        return get(this, 'file.preview', this.urlFor('thumbnail'));
    }

    urlFor(type = 'original') {
        const url = get(this, `file_data.${type}.id`);
        return url ? `${this.baseUrl}/${url}` : null;
    }

    save() {
        if (!this.file) { return Promise.resolve(this); }
        const form = new FormData();

        if (this.id) { form.append('id', this.id); }
        form.append('file', this.file, this.file.name);
        form.append('owner_type', this.owner.constructor.identifiedBy);
        form.append('owner_id', this.owner.identifierFieldValue);
        form.append('owner_association', this.owner_association_name);

        let url = `${Config.api_path}${Config.assets_path_prefix}`;
        const query   = {};
        if (Config.access_token) {
            query.jwt = Config.access_token;
        }
        if (!isEmpty(query)) {
            url += `?${qs.stringify(query, { arrayFormat: 'brackets' })}`;
        }
        return fetch(url, { method: 'POST', body: form })
            .then(resp => resp.json())
            .then((json) => {
                this.file = undefined;
                return json;
            }).then(json => this.set(json.data));
    }

}
