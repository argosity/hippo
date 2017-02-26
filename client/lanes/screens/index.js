import { computed } from 'mobx';
import { compact } from 'lodash';
import Instance from './instance';
import Definition from './definition';
import Group from './group';
import { createAsyncComponent } from 'react-async-component';

export default {

    @computed get active() {
        return Instance.active;
    },

    @computed get groups() {
        return Group.all;
    },

    @computed get displaying() {
        return Instance.displaying;
    },


    getDefinition(screenId) {
        return Definition.all.get(screenId);
    },

    setBrowserLocation(location) {
        let instance;
        const [instanceId, screenId, ...args] = Array.from(compact(location.pathname.split('/')));
        if (!screenId) { return; }
        if (instanceId) {
            instance = Instance.displaying.findInstance(screenId, instanceId);
        } else {
            instance = Instance.displaying.find((instance) => instance.screen.id === screenId);
        }
        if (instance) {
            instance.active = true;
        } else {
            this.display(screenId, { args });
        }
    },

    // display(screenId, props = {}) {
    //     const screen = Definition.all.get(screenId);
    //     if (!screen) {
    //         msg = `Unable to find screen definition for ${screenId}`;
    //         logger.warn(msg);
    //         Promise.reject(msg);
    //     }
    //     return new Instance({ screen, props, active: true });
    // },
};

// import { autorun, observable } from 'mobx';
// import { get, delay, extend } from 'lodash';

// import { classify, warn } from '../lib/util';
// import RequestAssets from '../lib/RequestAssets';

// import {
//     BaseModel, modelDecorator, session,
//     belongsTo, identifier, computed,
// } from '../models/base';
// import User from '../User';

// import ScreenDefinition from './definition';

// let Displaying;
// let All;


// All = observable.map([]);
// const registerScreen = (json) => {
//     const definition = new ScreenDefinition(json);
//     All.set(json.id, definition);
//     return definition;
// }

// const registerGroup = (json) => {
//     const group = new Group(json)
//     Groups.set(json.id, new Group(json));
//     return group;
// }

// export { All, registerScreen, registerGroup };


// @modelDecorator('ScreenViewSet')
// class ScreenViewSet extends BaseModel {

// //    static model = ScreenView;


//     active() {
//         return this.findWhere({ active: true });
//     }

//     constructor(models, options) {
//         super();
//         if (options == null) { options = {}; }
//         autorun(this::onUserChange);
//     }

//     onUserChange() {
//         if (User.isLoggedIn) {
//             get(User, 'options.initial_screens', []).forEach(
//                 screenId => All.get(screenId).display(),
//             );
//         } else {
//             this.reset();
//         }
//     }

//     remove(model) {
//         const index = this.indexOf(model);
//         super.remove(...arguments);
//         if (model.active && this.length) {
//             this.at(_.min([index, this.length - 1])).active = true;
//         }
//         model.active = false;
//         return this;
//     }

//     @computed onActiveChange(changed, active) {
//         if (!changed.active) { return; }
//         return this.each(function(screen) {
//             if (screen !== changed) { return screen.set({ active: false }); }
//         });
//     }

//     activateNext() { return this._moveActive(+1); }
//     activatePrev() { return this._moveActive(-1); }

//     _moveActive(inc) {
//         if (this.length === 1) { return; }
//         let current = this.findIndexWhere({ active: true });
//         if (current === -1) { return; }
//         if ((inc > 0) && (current === (this.length - 1))) {
//             current = -1;
//         }
//         if ((inc < 0) && (current === 0)) {
//             current = this.length;
//         }
//         return this.at(current + inc).active = true;
//     }

//     findInstance(screenId, instanceId) {
//         return this.find(instance => (instance.screen.id === screenId) && (instance.id === instanceId));
//     }
// }

//ScreenViewSet.initClass();

// @SerializableModel
// class ScreenSet extends BaseModel {

//     @observable.map models;

//     // static initClass() {
//     //     this.prototype.model = ScreenDefinition;
//     //     this.prototype.register = Lanes.emptyFn;
//     // }

//     get(id) {

//     }

//     addScreen(screen) {
//         const screen = this.add( screen );
//         return screen.set({active:true});
//     }

//     isLoading() {
//         return !!this.findWhere({loading: true});
//     }
// }





// @modelDecorator('MenuGroupSet')
// class MenuGroupSet extends BaseModel {
//     // static initClass() {
//     //     this.prototype.model = MenuGroup;
//     // }

//     constructor() {
//         super(...arguments);
//     }

//     available() {
//         return this.cache || (this.cache = new Lanes.Models.SubCollection(this, {
//             filter(group) {
//                 group.screens().filter();
//                 return group.screens().length > 0;
//             }
//         }));
//     }
// }


// Lanes.Screens.display_id = function(screen_id) {
//     const definition = Lanes.Screens.Definitions.all.get(screen_id);
//     if (definition) {
//         return definition.display();
//     } else {
//         return Lanes.warn(`Unable to find definition for screen ${screen_id}`);
//     }
// };


// Definitions = {

//     displaying: new ScreenViewSet([], { single_active_only: true }),
//     groups:  new MenuGroupSet,
//     register(spec) {
//         return this.all.add( spec );
//     },
//     setBrowserLocation(location) {
//         let instance;
//         const [instanceId, screenId, ...args] = Array.from(_.compact(location.pathname.split('/')));
//         if (!screenId) { return; }

//         if (instanceId && ( instance = this.displaying.findInstance(screenId, instanceId) )) {
//             return instance.active = true;
//         } else {
//             return __guard__(this.all.get(screenId), x => x.display({id: instanceId, props: {args}}));
//         }
//     }

// };

// Lanes.current_user.on("change:isLoggedIn", function(user) {
//     Lanes.Screens.Definitions.groups.each(group => delete group.cache);
//     delete Lanes.Screens.Definitions.groups.cache;

//     if (!user.isLoggedIn) {
//         return Lanes.Screens.Definitions.displaying.reset();
//     }
// });

// function __guardMethod__(obj, methodName, transform) {
//   if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
//     return transform(obj, methodName);
//   } else {
//     return undefined;
//   }
// }
// function __guard__(value, transform) {
//   return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
// }
