require "lanes"
require 'require_all'
require_relative "appy-app/version.rb"
require_relative "appy-app/extension.rb"

# The main namespace for Appy-app
module AppyApp
    def self.table_name_prefix
        "appy-app_"
    end
end

require_relative "appy-app/model"
require_rel "appy-app/models"
