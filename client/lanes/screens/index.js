import { observable, computed } from 'mobx';
import { map, filter, intersection } from 'lodash';
import Group from './group';
import Config from '../config';

const Screens = observable({

    all: observable.map(),

    active_screen_ids: observable.array(),

    get activeGroups() {
        const gids = Group.enabled_group_ids || map(Group.all, 'id');
        const groups = map(gids, gid => Group.forId(gid));
        return filter(groups, group => intersection(group.screens, this.active).length);
    },

    @computed get active() {
        return map(this.active_screen_ids, id => this.all.get(id));
    },

    configure(screen_ids) {
        this.active_screen_ids.replace(screen_ids);
    },

    reset() {
        this.active_screen_ids.clear();
    },

});

Config.screens = Screens;

export default Screens;
