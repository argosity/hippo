import SyncAdapter from './sync-adapter';

export default
class CollectionSync extends SyncAdapter {

    set data(rows) {
        this.array.replace(rows);
    }

    get record() {
        return this.array;
    }

    get url() {
        return this.syncUrl;
    }

}
