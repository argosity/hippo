require 'guard/cli'
require_relative '../guard_tasks'
module Lanes
    module Command

        class Server < Thor::Group
            include Thor::Actions

            def launch
                say "Launching testing server at http://localhost:8888/", :green
                require 'lanes/api'
                Lanes::Configuration.apply

                config = ClientConfig.new
                config.invoke_all

                API.webpack = Lanes::Command::Webpack.new([], wait: false)
                API.webpack.config = config

                API.webpack.invoke_all# startup

                ::Lanes::GuardTasks.client_config = config


                # threads = []
                # Thread.abort_on_exception = true
                # threads << Thread.new { API::Root.run! }
                # threads << Thread.new do
                #     sleep 1 until API::Root.running?
                #     trap("INT") do
                #         Lanes.logger.warn("trapped in subthread")
                #         API.webpack.stop!
                #         exit
                #     end
                #     Lanes.logger.info "ok, ctrl-c trap registered"
                # end
                sleep(1) # give webpack a bit of time to fail if it's going to
                unless API.webpack.process.alive?
                    puts API.webpack.messages
                    exit 1
                end
                Guard.start # will block until complete
                API.webpack.process.stop # stop webpack after guard completes
            end
        end
    end
end
