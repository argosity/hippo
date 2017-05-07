import { BaseModel as HippoBaseModel } from 'hippo/models/base';

export {
    identifiedBy, belongsTo, hasMany,
    action, autorun, field, session, identifier, observable, computed,
} from 'hippo/models/base';

export class BaseModel extends HippoBaseModel {


}
