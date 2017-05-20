require 'active_record'
require 'pathname'

module Hippo
    ROOT_PATH = Pathname.new(__FILE__).dirname.join('..')
end

require_relative "hippo/version"
require_relative "hippo/environment"
require_relative "hippo/configuration"
require_relative "hippo/redis"
require_relative "hippo/logger"
if defined?(::Rails)
    require_relative "hippo/rails_engine"
end
require_relative "hippo/db"
require_relative "hippo/strings"
require_relative "hippo/numbers"
require_relative "hippo/concerns/all"
require_relative "hippo/validators/all"
require_relative "hippo/model"
require_relative 'hippo/tenant'
require_relative "hippo/system_settings"
require_relative "hippo/asset"
require_relative "hippo/extension"
require_relative "hippo/screen"
require_relative "hippo/job"
require_relative "hippo/job/failure_logger"
require_relative "hippo/templates/base"
require_relative "hippo/templates/liquid"
require_relative "hippo/templates/latex"
require_relative "hippo/templates/mail"
require_relative "hippo/mailer"
require_relative 'hippo/user'
require_relative "hippo/access"
require_relative "hippo/workspace"
require_relative "hippo/webpack"
