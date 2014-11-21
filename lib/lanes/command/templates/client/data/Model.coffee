class Lanes.<%= namespace.camelize %>.Data.<%= class_name %> extends <%= client_parent %>

    api_path: '<%= name.downcase.pluralize.underscore.dasherize %>'

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
        <%= sprintf("%-#{max_field_length}s ",field.name) %>: { <%= field.belongs_to? ? 'model' : 'collection' -%>: "Lanes.<%= namespace.camelize %>.<%= field.name.camelize %>" }
<% end -%>
<% end -%>

class Lanes.<%= namespace.camelize %>.Data.<%= class_name %>.Collection extends <%= options[:client_collection_parent] %>

    model: Lanes.<%= namespace.camelize %>.Data.<%= class_name %>
