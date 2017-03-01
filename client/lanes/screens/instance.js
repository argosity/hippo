import { observable, autorun } from 'mobx';
import { extend, get, find } from 'lodash';
import {
    BaseModel, modelDecorator, session,
    belongsTo, identifier, computed,
} from '../models/base';

class InstanceCollection {

    @observable models = []
    @observable active;

    constructor() {
        autorun(() => this.onLengthChange());
    }

    onLengthChange() {
        const len = this.models.length;
        if (!len) { return; }
        if (len === 1) {
            this.active = this.models[0];
        } else if (!this.active) {
            this.active = this.models[len - 1];
        }
    }

    findInstance(screenId, instanceId) {
        return this.models.find(
            instance => (instance.definition.id === screenId)
                && (!instanceId || instance.id === instanceId),
        );
    }

    add(model) { this.models.push(model); }
    remove(model) { this.models.remove(model); }

}

const displaying = new InstanceCollection();
export { displaying };

@modelDecorator('lanes/screen-view')
export default class Instance extends BaseModel {

    static get displaying() {
        return displaying.models;
    }
    static get active() {
        return displaying.active;
    }

    @session({ type: 'object' }) props = {};
    @belongsTo({ model: 'lanes/screen/definition'}) definition;

    @identifier({ type: 'string' }) id;

    constructor(attrs) {
        super(attrs);

        if (!this.id) {
            this.id = Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 3);
        }
        this.props.screen = this;

        displaying.add(this);
        if (attrs.isActive){
            displaying.active = this;
        }
    }

    @computed get isActive() {
        return displaying.active === this;
    }

    set isActive(value) {
        displaying.active = this;
    }

    @computed get component() {
        return this.definition.component;
    }

    @computed get title() {
        let code = get(this.model, 'visibleIdentifier', '');
        if (code) { code = `::${code}`; }
        let { title } = this.definition;
        if (title.length > 12) { title = `${title.slice(0, 10)}…`; }
        return title + code;
    }

    @computed get historyUrl() {
        const code = get(this.model, 'visibleIdentifier', '');
        return { pathname: `/${this.id}/${this.definition.id}/${code}` };
    }

    remove() {
        displaying.remove(this);
    }
}
