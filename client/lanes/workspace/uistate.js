import { pick, findIndex } from 'lodash';
import {
    BaseModel, identifiedBy, field, session, belongsTo, hasMany, identifier, computed,
} from '../models/base';

const MENU_NARROW_WIDTH = 60;
const MENU_WIDE_WIDTH   = 250;
const NAVBAR_HEIGHT     = 50;
const BREAKPOINTS = {
    sm: 750,
    md: 970,
    lg: 1170,
};
const VALID_MENU_PREFS = [
    'menu-wide',
    'menu-narrow',
    'menu-hidden',
];


identifiedBy('UIState')
export default class UIState extends BaseModel {

    @session screenMenuPreference = '';
//    @session root:              'element',
//    @session menuView:         'any',
//    @session width  = 0; //; // :             'number',
//    @session height = 0; //:            'number',
    @session screenMenuShown = true; //: 'boolean',
    // layout:            'state',
    @belongsTo viewport;

//     static initClass() {
//         this.prototype.session = {
//        };

    @computed get screenMenuSize() {
        if (this.screenMenuPreference) { return this.screenMenuPreference; }
        switch (false) {
        case this.viewport.width >= (BREAKPOINTS.md + MENU_NARROW_WIDTH): return 'menu-hidden';
        case this.viewport.width >= (BREAKPOINTS.lg + MENU_WIDE_WIDTH):   return 'menu-narrow';
        default: return 'menu-wide';
        }
    }

    @computed get menuWidth() {
        switch (this.screenMenuSize) {
        case 'menu-wide': return 240;
        case 'menu-narrow': return 60;
        default: return 0;
        }
    }


    @computed get layoutSize() {
        switch (false) {
        case this.screensWidth >= BREAKPOINTS.sm: return 'xs';
        case this.screensWidth >= BREAKPOINTS.md: return 'sm';
        case this.screensWidth >= BREAKPOINTS.lg: return 'md';
        default: return 'lg';
        }
    }


    @computed get isMenuOverlayed() {
        // same as the below menu-hidden value on screen_menu_size
        return this.viewport.width < (BREAKPOINTS.md + MENU_NARROW_WIDTH);
    }


    @computed get screensWidth() {
        return this.viewport.width - (this.isMenuOverlayed ? 0 : this.menuWidth);
    }

    @computed get screensHeight() {
        return this.viewport.height - NAVBAR_HEIGHT;
    }

    nextSidebarState() {
        if (!this.screenMenuPreference) {
            this.screenMenuPreference = this.screenMenuSize;
        }
        if (this.isMenuOverlayed) {
            this.screenMenuPreference = this.screenMenuPreference === 'menu-wide' ? 'menu-hidden' : 'menu-wide';
        } else {
            const len = VALID_MENU_PREFS.length;
            let newIndex = VALID_MENU_PREFS.indexOf(this.screenMenuPreference) + 1;
            if (newIndex > (len - 1)) newIndex = 0;
            this.screenMenuPreference = VALID_MENU_PREFS[newIndex];
        }
    }
}
