class <%= namespace.camelize %>.Models.<%= class_name %> extends <%= namespace.camelize %>.Models.Base

    api_path: '<%= name.downcase.pluralize.underscore.dasherize %>'
    FILE: FILE

    props:
<% fields.each do |field| -%>
<% if field.reference? -%>
        <%= sprintf("%-#{max_field_length}s",field.name+'_id') %>: "<%= field.client_type %>"
<% else -%>
        <%= sprintf("%-#{max_field_length}s",field.name) %>: "<%= field.client_type %>"
<% end -%>
<% end %>
<% if reference_fields.any? -%>

    associations:
<% reference_fields.each do |field| -%>
        <%= sprintf("%-#{max_field_length}s ",field.name) %>: { <%= field.belongs_to? ? 'model' : 'collection' -%>: "<%= namespace.camelize %>.<%= field.name.camelize %>" }
<% end -%>
<% end -%>
