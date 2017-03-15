import { includes, get, isEmpty } from 'lodash';
import qs from 'qs';
import { autorun } from 'mobx';
import {
    BaseModel, identifiedBy, field, session, identifier, computed,
} from './base';
import Config from '../config';

const IMAGES = [
    'image/png', 'image/jpeg', 'image/gif',
];

const IS_IMAGE = content_type => !!(content_type && (-1 !== IMAGES.indexOf(content_type)));

const UPDATE_METHODS = { POST: true, PUT: true, PATCH: true };

@identifiedBy('lanes/asset')
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
        autorun(() => {
            if (this.isDirty && UPDATE_METHODS[get(this.owner, 'syncInProgress.method')]) {
                this.save();
            }
        });
    }

    @computed get baseUrl() {
        return `${Config.api_path}/asset`;
    }

    @computed get isDirty() {
        return !!this.file;
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
        form.append('owner_id', this.owner.identifier);
        form.append('owner_association', this.owner_association_name);

        let url = `${Config.api_path}/asset`;
        const query   = {};
        if (Config.access_token) {
            query.jwt = Config.access_token;
        }
        if (!isEmpty(query)) {
            url += `?${qs.stringify(query, { arrayFormat: 'brackets' })}`;
        }
        return fetch(url, { method: 'POST', body: form });
    }

}
