    screens.define "<%= screen_id %>" do | screen |
        screen.title       = "<%= options[:title] %>"
        screen.description = "<%= options[:description] %>"
        screen.icon        = "<%= options[:icon] %>"
        screen.group_id    = "<%= options[:group] %>"
        screen.model_class = "<%= options[:model_class] %>"
        screen.view_class  = "<%= class_name %>"
<% unless options[:fileless] -%>
        # Can optionally explicity set files to be included
        # screen.js          = "<%= screen_id %>.js"
        # screen.css         = "<%= screen_id %>.css"
<% end -%>
    end
