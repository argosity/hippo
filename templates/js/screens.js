import Definition, { createAsyncComponent } from 'lanes/screens/definition';
import Group from 'lanes/screens/group';

const isDev = (process.env.NODE_ENV === 'development');

<% Lanes::Screen.each_group do | group | %>
Group.register( <%= group.to_json %> );
<% end %>

<% Lanes::Screen.each do | screen | %>

    Definition.register(
        <%= screen.to_json %>,
        createAsyncComponent({ resolve: () =>
                               System.import(<%= "'#{screen.asset}'" %>)
                             })
    );
<% end %>
