import { observable } from 'mobx';
import {
    BaseModel, identifiedBy, session, identifier,
} from '../models/base';

const All = observable.array();

@identifiedBy('ScreensGroup')
export default class ScreensGroup extends BaseModel {

    static all = All;

    @identifier({ type: 'string' }) id;
    @session title;
    @session description;
    @session icon;
    @session active = false;

    @session({ type: 'array' }) screens;

    static forId(groupId) {
        return All.find(g => g.id === groupId);
    }
    static register(json) {
        let group = this.forId(json.id);
        if (!group) {
            group = new ScreensGroup(json);
            All.push(group);
        } else {
            group.update(json);
        }
        return group;
    }

}
