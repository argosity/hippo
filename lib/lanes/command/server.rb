require 'guard/cli'

module Lanes
    module Command

        class Server < Thor::Group
            include Thor::Actions

            class_option  :port, type: :numeric

            def launch
                say "Launching testing server at http://localhost:8888/", :green
                Guard.start
            end
        end

    end

end
