require 'guard/cli'
require_relative '../webpack'

module Lanes
    module Command

        class Server < Thor::Group
            include Thor::Actions

            def launch
                say "Launching testing server at http://localhost:8888/", :green
                require 'lanes/api'
                Lanes::Configuration.apply

                API.webpack = Lanes::Webpack.server

                threads = []
                Thread.abort_on_exception = true
                threads << Thread.new { API::Root.run! }
                threads << Thread.new do
                    sleep 1 until API::Root.running?
                    trap("INT") do
                        Lanes.logger.warn("trapped in subthread")
                        API.webpack.stop!
                        exit
                    end
                    Lanes.logger.info "ok, ctrl-c trap registered"
                end

                API.webpack.start

                sleep(1) # give webpack a bit of time to fail if it's going to

                unless API.webpack.alive?
                    puts API.webpack.messages
                    exit 1
                end

                Guard.start

                API.webpack.stop
            end
        end
    end
end
