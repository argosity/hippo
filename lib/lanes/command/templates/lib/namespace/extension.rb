require_relative '../<%= identifier %>'

module <%= namespace %>

    class Extension < Lanes::Extensions::Definition

        identifier "<%= identifier %>"

        root_path Pathname.new(__FILE__).dirname.join("..","..").expand_path

    end

end
