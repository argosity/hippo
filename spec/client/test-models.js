import { merge } from 'lodash';
import {
    BaseModel,
    identifiedBy,
    observable,
    field, session, belongsTo, hasMany, identifier, computed,
} from 'hippo/models/base';
import { BaseExtension } from 'hippo/extensions/base';
import ScreenDefinition from 'hippo/screens/definition';

@identifiedBy('test/boat')
export class Ship extends BaseModel {
    @identifier({ type: 'string' }) name;

    @belongsTo({ model: 'test/container', inverseOf: 'vessel' }) container;
}


@identifiedBy('test/model/image')
export class TestImage extends BaseModel {
    @identifier id;
    @belongsTo({ inverseOf: 'owner', model: 'hippo/asset' }) asset;
    @observable syncInProgress = false;

    save() {
        this.syncInProgress = { method: 'POST' };
    }
}


@identifiedBy('test/box')
export class Box extends BaseModel {

    @session visibleIdentifier;

    @session({ type: 'string' }) label;

    @identifier id;

    @field({ type: 'number' }) width  = 1;
    @field height = 1;
    @field depth  = 1;

    @computed get volume() {
        return this.width * this.height * this.depth;
    }

    @belongsTo container;
}

@identifiedBy('test/container')
export class Container extends BaseModel {

    @identifier({ type: 'string' }) id;

    @field name;
    @field location;
    @session currentValue;

    @computed get description() {
        return `${this.name} ${this.location}`;
    }

    @hasMany({ model: 'test/box', inverseOf: 'container' }) boxes;

    @belongsTo vessel;
    @belongsTo({ model: 'boat' }) watercraft;

    @computed get areaInUse() {
        return this.boxes.reduce((acc, box) => (acc + box.volume), 0);
    }
}

export function getTestScreen(attrs = {}) {
    return ScreenDefinition.register(merge({
        id: 'test',
        title: 'title',
        icon: 'red',
        component: {},
        model: 'test/box',
        view:  'view_class',
        assets: ['test.js', 'test.css'],
        access: 'test/box',
        group_id: 'group_id',
        extension_id: 'test',
        url_prefix: 'test',
        description: 'description',
    }, attrs));
}

export class TestExtension extends BaseExtension {
    get id() { return 'test'; }
}
TestExtension.register();
