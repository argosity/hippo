require_relative '../lanes'
require_relative 'api/request_wrapper'
require_relative 'api/error_formatter'
require_relative 'api/formatted_reply'
require_relative 'api/controller'
require_relative 'api/root'

Lanes.config.get(:environment) do
    require_relative("api/test_specs") unless Lanes.env.production?
end


require_relative 'api/default_routes'
