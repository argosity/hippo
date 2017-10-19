import Config from 'hippo/config'

<% Hippo::Extensions.each do | ext | %>
    <% name = ext.identifier + 'Ext' %>
import <%= name %> from '<%= ext.client_extension_path %>';
<%= name %>.register();

<% end %>

Config.update(<%= Hippo::Extensions.static_bootstrap_data.to_json %>);
