import { isNil, get, includes, extend, pick } from 'lodash';
import { titleize } from '../../lib/util';
import {
    BaseModel, modelDecorator, field, session,
    belongsTo, hasMany, identifier, computed, observable,
} from '../base';

@modelDecorator('lanes/query/field')
export default class Field extends BaseModel {

    @identifier({ type: 'string' }) id;
    @session title;
    @session selected   = false;
    @session editable   = true;
    @session width      = 100;
    @session flexGrow   = 1;
    @session flexShrink = 1;
    @session visible    = true;
    @session loadable   = true;
    @session queryable  = true;
    @session sortable   = true;
    @session textAlign  = 'left';

    @session fetchIndex;
    @session sortBy;

    @observable format;
    @observable component;
    @observable onColumnClick;

    @belongsTo query;

    @computed get isSortingBy() {
        return this === this.query.sortField;
    }

    @computed get label() {
        return this.title ? this.title : titleize(this.id);
    }

    @computed get queryType() {
        return get(this.query.src.propertyOptions[this.id], 'type', 'string');
    }

    @computed get isNumeric() {
        return includes(['number'], this.queryType);
    }

    @computed get visibleIndex() {
        if (!this.visible) { return null; }
        let index = 0;
        for (let i = 0; i < this.query.fields.length; i += 1) {
            if (this.query.fields[i].visible) {
                if (this.query.fields[i] === this) {
                    return index;
                }
                index += 1;
            }
        }
        return null;
    }

    @computed get dataIndex() {
        if (!this.loadable) { return null; }

        let index = 0;
        for (let i = 0; i < this.query.fields.length; i += 1) {
            if (this.query.fields[i].loadable) {
                if (this.query.fields[i] === this) {
                    return index;
                }
                index += 1;
            }
        }
        return null;
    }



}

// class AvailableFields {
//     static initClass() {
//         this.prototype.model = Field;
//     }

//     constructor(models, options) {
//         this.query = options.query;
//         this.on('add remove reset', this.calculateFetchIndexes);
//         this.on('change', function (changing) {
//             if (!changing.selected) { return; }
//             return (() => {
//                 const result = [];
//                 for (const model of Array.from(this.models)) {
//                     let item;
//                     if (model !== changing) { item = model.selected = false; }
//                     result.push(item);
//                 }
//                 return result;
//             })();
//         });
//         super(...arguments);
//         this.visible = this.subcollection({ where: { visible: true } });
//         this.calculateFetchIndexes();
//     }

//     calculateFetchIndexes() {
//         let index = 0;
//         return Array.from(this.models).map(field =>
//             field.fetchIndex = field.query ? index++ : undefined);
//     }
// }
// AvailableFields.initClass();


        // this.prototype.session = {
        //     id: { type: 'string',
        //     },
        //     title: { type: 'string',
        //     },
        //     selected: { type: 'boolean',
        //     },
        //     visible: { type    : 'boolean', default : true,
        //     },
        //     query: { type    : 'boolean', default : true,
        //     },
        //     editable: { type    : 'boolean', default : true,
        //     },
        //     sortable: { type    : 'boolean', default : true,
        //     },
        //     format: { type: 'function',
        //     },
        //     flex: { type    : 'number', default : 1,
        //     },
        //     fixedWidth: { type: 'number',
        //     },
        //     textAlign: { type    : 'string', default : 'left',
        //     },
        //     sortBy: { type: 'any',
        //     },
        //     component: { type: 'function',
        //     },
        //     onColumnClick: { type: 'function',
        //     },
        //     fetchIndex: { type: 'integer',
        //     },
        // };

    // @calculated get model_field() {
    //     this.query.model.
    // }
    //     this.prototype.derived = {
    //         default_value: { deps: ['id'], fn() {
    //             switch (this.model_field.type) {
    //             case 'integer': return 0;
    //             default: return '';
    //             }
    //         },
    //         },
    //         model_field: {
    //             deps: ['id'], fn() {
    //                 return this.collection.query.model.prototype._definition[this.id];
    //             },
    //         },
    //         type: {
    //             deps: ['model_field'], fn() {
    //                 const type = __guard__(this.model_field, x => x.type) || 'string';
    //                 if ('code' === type) { return 'string'; } else { return type; }
    //             },
    //         },
    //     };
    // }

    // constructor(attributes) {
    //     super(_.defaults(attributes, {
    //         title: _.titleize(_.humanize(attributes.id)),
    //     }));
    // }

    // validValue(value) {
    //     if ('n' === this.type) {
    //         return !_.isNaN(parseFloat(value));
    //     } else {
    //         return value;
    //     }
    // }
//}
