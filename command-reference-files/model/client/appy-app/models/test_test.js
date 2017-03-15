import {
    BaseModel, identifiedBy, identifier, belongsTo, hasMany, field, computed
} from './base';

@identifiedBy('appy-app/test_test')
export default class TestTest extends BaseModel {

    @identifier id;
    @field      name;
    @field      email;

}
