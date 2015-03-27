class <%= namespace.camelize %>.Screens.<%= class_name %> extends <%= namespace.camelize %>.Screens.Base

<% if @template -%>
    template: '''
        <%= @template %>
    '''
<% end -%>

    subviews: {}

    events: {}
