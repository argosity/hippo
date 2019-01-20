import { isArray, defaults, extend } from 'lodash';
import { computed, observable } from 'mobx';
import SyncAdapter from './sync-adapter';
import lazyGetter from '../lib/lazy-getter';

export default
class ModelSync extends SyncAdapter {

    static lazyCreate = lazyGetter;

    pending = {
        save: observable.map(),
        fetch: observable.map(),
        delete: observable.map(),
    };

    @computed get isDeleting() {
        return 0 !== this.pending.delete.size;
    }

    @computed get isSaving() {
        return 0 !== this.pending.save.size;
    }

    get record() {
        return this.model;
    }

    set data(data) {
        if (!data) { return this.model; }
        if (isArray(data) && data.length) {
            this.model.update(data[0]);
        } else {
            this.model.update(data);
        }
        return this;
    }

    @computed get data() {
        return this.model.serialize();
    }

    get url() {
        const path = this.model.constructor.syncUrl;
        return this.model.isNew ? path : `${path}/${this.model.identifierFieldValue}`;
    }

    save(options = {}) {
        return this.sync('save', defaults(options, {
            action: this.model.isNew ? 'create' : 'update',
        }));
    }

    destroy(options = {}) {
        return this.sync('delete', extend(options, {
            action: 'destroy',
        }));
    }

}
