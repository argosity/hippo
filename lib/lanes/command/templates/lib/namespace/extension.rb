require_relative '../<%= name %>'

module <%= namespace %>

    class Extension < Lanes::Extensions::Definition

        identifier "<%= name %>"

        root_path Pathname.new(__FILE__).dirname.join("..","..").expand_path

    end

end
