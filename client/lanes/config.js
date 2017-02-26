import { observable, autorun } from 'mobx';
import { keysIn, pick, assign, isString } from 'lodash';
import Extensions from './extensions';


class Config {

    @observable api_host = '';
    @observable api_path = '/api';
    @observable access_token;
    @observable root_view;
    @observable assets_path_prefix = '/assets'


    constructor() {
        autorun(() => this.onTokenChange());
    }

    bootstrap(attrs) {
        assign(this, pick(attrs, keysIn(this)));
        Extensions.setBootstrapData(attrs);
    }

    onTokenChange() {
        /* global window: true  */
        if (!window.localStorage) { return; }
        if (isString(this.access_token)) {
            window.localStorage.setItem('token', this.access_token);
        } else {
            this.access_token = window.localStorage.getItem('token');
        }
        /* global window: false  */
    }
}

const ConfigInstance = new Config();
export default ConfigInstance;



    // static initClass() {

    //     this.prototype.mixins = [ Lanes.Models.Mixins.FileSupport ];

    //     this.prototype.props = {
    //         id:       {type:"integer"},
    //         settings: "object"
    //     };

    //     this.prototype.associations = {
    //         logo:        { model: "Lanes.Models.Asset"        },
    //         smtp:        { model: "Lanes.Models.SmtpSettings" },
    //         print_logo:  { model: "Lanes.Models.Asset"        }
    //     };
    // }

    // modelTypeIdentifier() { return 'system-settings'; }
    // url() { return Lanes.config.api_path + '/system-settings'; }
    // initialize() {
    //     this.on('change:settings', this.setDefaultSettings);
    //     this.smtp.set(__guard__(__guard__(this.settings, x1 => x1.lanes), x => x.smtp));
    //     return this.setDefaultSettings();
    // }

    // setDefaultSettings() {
    //     if (!this.settings) { this.settings = {}; }
    //     return this.settings.lanes || (this.settings.lanes = {});
    // }

    // forExtension(ext) {
    //     return this.settings[ext] || (this.settings[ext] = {});
    // }

    // setValueForExtension(ext, key, value) {
    //     return this.forExtension(ext)[key] = value;
    // }

    // set(data) {
    //     let ret = super.set(...arguments);
    //     this.smtp.set(__guard__(__guard__(this.settings, x1 => x1.lanes), x => x.smtp));
    //     return ret;
    // }

    // dataForSave() {
    //     let data = super.dataForSave(...arguments);
    //     data.settings.lanes.smtp = this.smtp.serialize();
    //     return data;
    // }


// SystemSettings.initClass();

// class Config extends Lanes.Models.State {
//     static initClass() {

//         this.prototype.session = {
//             csrf_token:  { type: 'string', setOnce: true     },
//             root_path:   { type: 'string', setOnce: true     },
//             api_path:    { type: 'string', default: '/api'   },
//             environment: { type: 'string', setOnce: true     },
//             system_settings: { type: 'state', required: true },
//             assets_path_prefix: { type: 'string', setOnce: true },
//             api_host:    { type: 'string', default: `//${window.location.host }` },
//             initial_workspace_screen_id: { type: 'string', setOnce: true      }
//         };

//         this.prototype.derived = {
//             env: {
//                 deps: ['environment'], fn() {
//                     return {
//                         test:        this.environment === 'test',
//                         development: this.environment === 'development',
//                         production:  this.environment === 'production'
//                     };
//                 }
//             }
//         };
//     }

//     initialize() {
//         return this.system_settings = new SystemSettings;
//     }

//     bootstrap(options) {
//         if (options.system_settings) {
//             this.system_settings.set(options.system_settings);
//             delete options.system_settings;
//         }
//         this.set(options);
//         if (_.isObject(options)) { return Lanes.Extensions.setBootstrapData(options); }
//     }
// }
// Config.initClass();

// let configInstance = new Config;

// Object.defineProperty(Lanes, 'config', {
//     get() { return configInstance; },
//     set() { throw new Error("Unable to reset config"); }
// }
// );

// function __guard__(value, transform) {
//   return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
// }
