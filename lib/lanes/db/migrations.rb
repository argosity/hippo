require 'pathname'

module Lanes
    module DB
        module Migrations
            # The `paths` array is an extension point for other
            mattr_accessor :paths
            self.paths = [
              Pathname.new(__FILE__).dirname.join("../../../db/migrate").realpath
            ]
        end
    end
end
