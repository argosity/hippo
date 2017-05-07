require "hippo"
require 'require_all'
require_relative "appy-app/version.rb"
require_relative "appy-app/extension.rb"

# The main namespace for AppyApp
module AppyApp

    def self.system_settings
        Hippo::SystemSettings.for_ext('appy-app')
    end

end

require_relative "appy-app/model"
