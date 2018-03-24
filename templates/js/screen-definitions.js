import Definition, { asyncComponent } from 'hippo/screens/definition';
import Group from 'hippo/screens/group';

<% Hippo::Screen.each_group do | group | %>
Group.register( <%= group.to_json %> );
<% end -%>

const Screens = {};

<% Hippo::Screen.each do | screen | -%>
Screens['<%= screen.identifier %>'] = <%= screen.to_json %>;
Definition.register(
    Screens['<%= screen.identifier %>'],
    asyncComponent({
        screen: <%= screen.to_json %>,
        resolve: () => import(<%= "'#{screen.asset_path}'" %>)
    }),
);
<% end -%>

<% if Hippo::Screen.enabled_group_ids %>
Group.enabled_group_ids = [<%= Hippo::Screen.enabled_group_ids.map{ |gid| "'#{gid}'" }.join(',') %>];
<% end %>
