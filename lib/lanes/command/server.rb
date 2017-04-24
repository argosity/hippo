require 'guard/cli'
require_relative '../guard_tasks'
require_relative '../multi_server_boot'

module Lanes
    module Command

        class Server < Thor::Group

            include Thor::Actions

            def launch
                say "Launching testing server at http://localhost:8888/", :green
                Command.load_current_extension
                ::Lanes::MultiServiceBoot.perform
            end
        end
    end
end
