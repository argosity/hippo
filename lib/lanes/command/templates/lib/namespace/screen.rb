require 'lanes'

module <%= namespace.camelize %>

    class <%= class_name %>Screen < Lanes::Screens::Definition

        identifier  "<%= name.dasherize %>"
        title       "<%= options[:title] %>"
        description "<%= options[:description] %>"
        icon        "<%= options[:icon] %>"
        group_id    "<%= options[:group] %>"
        model_class "<%= options[:model_class] %>"
        view_class  "Lanes.Screens.<%= class_name %>"
        files       ['screens/<%= name.dasherize %>.js','screens/<%= name.dasherize %>.css']
    end

end
