Lanes::Screen.define "<%= identifier %>" do | screen |
    screen.description = "<%= options[:description] %>"
    screen.icon        = "<%= options[:icon] %>"
    screen.group_id    = "<%= options[:group] %>"
    screen.model_class = "<%= options[:model_class] %>"
    screen.view_class  = "<%= namespace %>.Screens.<%= class_name %>"
<% unless options[:fileless] -%>
    screen.files       = ["<%= identifier %>/screens/<%= name.dasherize %>.js","<%= identifier %>/screens/<%= name.dasherize %>.css"]
<% end -%>
end
