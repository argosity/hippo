class <%= namespace.camelize %>.Screens.<%= class_name %> extends Lanes.Screens.Base

    FILE: FILE
<% if @template -%>
    template: '''
        <%= @template %>
    '''
<% end -%>

    subviews: {}

    events: {}
