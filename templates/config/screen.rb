
Lanes::Screen.define "<%= screen_id %>" do | screen |
    screen.description = "<%= options[:description] %>"
    screen.icon        = "<%= options[:icon] %>"
    screen.group_id    = "<%= options[:group] %>"
    screen.model_class = "<%= options[:model_class] %>"
    screen.view_class  = "<%= namespace %>.Screens.<%= class_name %>"
<% unless options[:fileless] -%>
    screen.js          = "<%= identifier %>/screens/<%= screen_id %>.js"
    screen.css         = "<%= identifier %>/screens/<%= screen_id %>.css"
<% end -%>
end
