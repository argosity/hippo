require 'active_record'

module Lanes
    ROOT_PATH = Pathname.new(__FILE__).dirname.join('..')
end

require_relative "lanes/version"
require_relative "lanes/environment"
require_relative "lanes/configuration"
require_relative "lanes/redis"
require_relative "lanes/logger"
if defined?(::Rails)
    require_relative "lanes/rails_engine"
end
require_relative "lanes/db"
require_relative "lanes/strings"
require_relative "lanes/numbers"
require_relative "lanes/concerns/all"
require_relative "lanes/validators/all"
require_relative "lanes/model"
require_relative "lanes/system_settings"
require_relative "lanes/asset"
require_relative "lanes/components"
require_relative "lanes/extension"
require_relative "lanes/screen"
require_relative "lanes/job"
require_relative "lanes/job/failure_logger"
require_relative "lanes/mailer"
