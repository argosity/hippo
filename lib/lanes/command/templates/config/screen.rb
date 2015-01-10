Lanes::Screen.define "<%= name.dasherize %>" do | screen |
    screen.description = "<%= options[:description] %>"
    screen.icon        = "<%= options[:icon] %>"
    screen.group_id    = "<%= options[:group] %>"
    screen.model_class = "<%= options[:model_class] %>"
    screen.view_class  = "<%= namespace.camelize %>.Screens.<%= class_name %>"
    screen.files       = ["<%= namespace %>/screens/<%= name.dasherize %>.js","<%= namespace %>/screens/<%= name.dasherize %>.css"]
end
