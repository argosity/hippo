import { observable } from 'mobx';
import { get } from 'lodash';
import {
    BaseModel, identifiedBy, session,
    belongsTo, identifier, computed,
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
        return All.find((g)=> g.id === groupId);
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

    // constructor() {
    //     super();
    // }

    // @computed get screens() {

    //     // return this.cache || (this.cache = new Lanes.Models.SubCollection( Lanes.Screens.Definitions.all, {
    //     //     filter: screen => {
    //     //         return (screen.group_id === this.id) &&
    //     //             (!screen.model_type || Lanes.current_user.hasAccess(screen.access, screen.model_type));
    //     //     },
    //     //     watched: ['group_id']
    //     // }));
    // }
}
