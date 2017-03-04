import {
    BaseModel, identifiedBy, identifier, belongsTo, hasMany, field, computed
} from './base';

@identifiedBy('<%= identifier %>/<%= file_name %>')
export default class <%= class_name %> extends BaseModel {

<% fields.each do |field| -%>
    @<%= sprintf("%-11s%s;", field.decorator, field.column_name ) %>
<% end -%>

<% if reference_fields.any? -%>
<% reference_fields.each do |field| -%>
    @<%= field.belongs_to? ? 'belongsTo' : 'hasMany' -%>({ model: '<%= identifier %>/<%= field.name %>' }) <%= field.name %>;
<% end -%>
<% end -%>
}
