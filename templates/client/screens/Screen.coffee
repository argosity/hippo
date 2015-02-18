class <%= namespace.camelize %>.Screens.<%= class_name %> extends <%= namespace.camelize %>.Screens.Base

    FILE: FILE
<% if @template -%>
    template: '''
        <%= @template %>
    '''
<% end -%>

    subviews: {}

    events: {}
