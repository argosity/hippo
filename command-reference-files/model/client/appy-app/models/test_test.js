import {
    BaseModel, identifiedBy, identifier, field, session, belongsTo, hasMany,
} from './base';

@identifiedBy('appy-app/test_test')
export default class TestTest extends BaseModel {

    @identifier id;
    @field      name;
    @field      email;

}
