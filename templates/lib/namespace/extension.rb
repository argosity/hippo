require_relative "../<%= identifier %>"

# This will load the "Workspace" extension, which provides
# a menu and tab based switching between screens.
require "lanes/workspace/extension"

# This will load the "Access" extension, which provides
# Role based user access controls.  Before enabling it
# make sure that you have created some users in db/seed.rb
#
# require "lanes/workspace/access"


module <%= namespace %>

    class Extension < Lanes::Extensions::Definition

        identifier "<%= identifier %>"

        root_path Pathname.new(__FILE__).dirname.join("..","..").expand_path

    end

end
