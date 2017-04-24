import Config from 'lanes/config'

<% Lanes::Extensions.each do | ext | %>
    <% name = ext.identifier + 'Ext' %>
import <%= name %> from '<%= ext.client_extension_path %>';
<%= name %>.register();

<% end %>

Config.bootstrap(<%= Lanes::Extensions.client_bootstrap_data.to_json %>);