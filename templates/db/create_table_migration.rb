class Create<%= class_name.pluralize %> < ActiveRecord::Migration[5.0]
    def change
        create_table :<%= table_name %> do |t|
<% fields.each do |attribute| -%>
<% if attribute.password_digest? -%>
            t.string :password_digest<%= attribute.inject_options %>
<% else -%>
            t.<%= attribute.type %> :<%= attribute.name %><%= attribute.inject_options %>
<% end -%>
<% end -%>
<% if options[:timestamps] %>
            t.timestamps null: false
<% end -%>
        end
<% fields_with_index.each do |attribute| -%>
        add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>
<% end -%>
    end
end
