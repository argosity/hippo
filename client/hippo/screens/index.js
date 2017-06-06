import { observable, computed } from 'mobx';
import { map, filter, intersection } from 'lodash';
import Group from './group';
import Config from '../config';

const Screens = observable({

    all: observable.map(),

    get activeGroups() {
        const gids = Group.enabled_group_ids || map(Group.all, 'id');
        const groups = map(gids, gid => Group.forId(gid));
        return filter(groups, group => intersection(group.screens, this.active).length);
    },

    @computed get active() {
        return map(Config.screen_ids, id => this.all.get(id));
    },

    reset() {
        Config.screen_ids.clear();
    },

});

export default Screens;
