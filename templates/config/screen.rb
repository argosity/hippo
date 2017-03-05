    screens.define "<%= screen_id %>" do | screen |
        screen.title       = "<%= options[:title] %>"
        screen.description = "<%= options[:description] %>"
        screen.icon        = "<%= options[:icon] %>"
        screen.group_id    = "<%= options[:group] %>"
        screen.model_class = "<%= options[:model_class] %>"
        screen.view_class  = "<%= class_name %>"
        screen.asset       = "<%= screen_id %>"
    end
