import Asset from 'hippo/models/asset';
import { action, computed, toJS } from 'mobx';
import {
    BaseModel, identifiedBy, identifier, field, hasMany,
} from './base';

@identifiedBy('hippo/page')
export default class Page extends BaseModel {

    @identifier id;

    @field html = '';

    @field({ type: 'object' }) contents;

    @field({ type: 'object' }) owner;

    @field owner_id;

    @field owner_type;

    @hasMany({ model: Asset, inverseOf: 'owner' }) images;

    @computed get editorContent() {
        return this.contents.length ? toJS(this.contents) : [];
    }

    static hasPageMixin(Base) {
        return class extends Base {

            @action findOrCreatePage() {
                if (!this.page) {
                    this.page = new Page({
                        owner: this, owner_id: this.id, owner_type: this.constructor.serverModel,
                    });
                    if (!this.isNew) { this.page.save(); }
                }
                return this.page;
            }

        };
    }

}
