import React from 'react';
import { merge } from 'lodash';
import {
    BaseModel, modelDecorator, field, session, belongsTo, hasMany, identifier, computed,
} from 'lanes/models/base';
import BaseExtension from 'lanes/extensions/base';
import ScreenDefinition from 'lanes/screens/definition';
import UiState  from 'lanes/workspace/uistate';
import Viewport from 'lanes/react/viewport';

@modelDecorator('test/box')
export class Box extends BaseModel {

    @session visibleIdentifier;
    @session bar;
    @identifier id;

    @field width  = 1;
    @field height = 1;
    @field depth  = 1;

    @computed get volume() {
        return this.width * this.height * this.depth;
    }

    @belongsTo container;
}

@modelDecorator('test/container')
export class Container extends BaseModel {

    @identifier id;

    @field name;
    @field location;
    @session currentValue;

    @computed get description() {
        return `${this.name} ${this.location}`;
    }

    @hasMany({ className: 'Box', inverseOf: 'container' }) boxes;

    @computed get areaInUse() {
        return this.boxes.reduce((acc, box) => (acc += box.volume), 0);
    }
}

export function getTestScreen(attrs = {}){
    return ScreenDefinition.register(merge({
        id: 'test', title: 'title', icon: 'red',
        model: 'Test/Box', view:  'view_class', assets: ['test.js', 'test.css'],
        access: 'test/box', group_id: 'group_id', extension_id: 'test',
        url_prefix: 'test', description: 'description'
    }, attrs));
}

export class ReactContext {
    constructor() {

        const container = document.createElement('div');
        const viewport = new Viewport({ container, useHistory: false });
        const uistate = new UiState({ viewport });
        this.context = { viewport, uistate };
        this.childContextTypes = {
            viewport: React.PropTypes.object,
            uistate:  React.PropTypes.object,
        };
    }
}

export class TestExtension extends BaseExtension {
    get identifier() { return 'test'; }
}
TestExtension.register();
