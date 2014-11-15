require_relative 'api/authentication_helper'
require_relative 'api/authentication_provider'

require_relative 'api/request_wrapper'
require_relative 'api/error_formatter'
require_relative 'api/controller'
require_relative 'api/root'
require_relative 'api/default_routes'
# require_relative 'api/login_sessions_controller'
# require_relative 'api/users_controller'

require_relative "api/pub_sub"


Lanes.config.get(:environment) do
    require_relative("api/test_specs") if Lanes.env.test?
end

# Lanes::API::Root.routes['GET'].each do |route|
#   puts route[0]
# end

# require_relative "api/skr_templates"
# if defined?(::Rails)
#     require_relative "api/engine"
#     require_relative "api/route_helper"
# end
