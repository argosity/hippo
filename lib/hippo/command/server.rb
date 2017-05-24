require 'guard/cli'
require_relative '../guard_tasks'

module Hippo
    module Command

        class Server < Thor::Group

            include Thor::Actions

            def launch
                say "Launching testing server at http://localhost:8888/", :green
                Guard.start # will block until complete
            end
        end
    end
end
