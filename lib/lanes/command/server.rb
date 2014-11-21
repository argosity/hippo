require 'guard'

module Lanes
    module Command

        class Server < Thor::Group
            include Thor::Actions

            class_option  :port, type: :numeric

            def launch
                Guard.start
            end
        end

    end

end
