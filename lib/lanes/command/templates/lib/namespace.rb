require "lanes"
require 'require_all'
require_relative "<%= identifier %>/version.rb"
require_relative "<%= identifier %>/extension.rb"
require_rel '<%= identifier %>'

# The main namespace for <%= name.camelize %>
module <%= namespace %>
    def self.table_name_prefix
        "<%= name %>_"
    end
end
