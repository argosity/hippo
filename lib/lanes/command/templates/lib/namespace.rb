require "lanes"
require 'require_all'
require_relative "<%= name %>/version.rb"
require_relative "<%= name %>/extension.rb"
require_rel '<%= name %>'

# The main namespace for <%= name.camelize %>
module <%= namespace.camelize %>
    def self.table_name_prefix
        "<%= name %>_"
    end
end
