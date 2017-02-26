require 'guard/cli'
require 'webpack_driver'
require 'puma/cli'
require 'guard/jest'
#require 'lanes/api'
require_relative '../webpack'
require_relative 'jest_runner'

require_relative '../access/extension'

module Lanes
    module Command

        class Server < Thor::Group
            include Thor::Actions

 #           class_option  :port, type: :numeric

            # cattr_accessor :staging_dir #, :config
#            class_option :webpack

            def launch
                say "Launching testing server at http://localhost:8888/", :green
                require 'lanes/api'
                Lanes::Configuration.apply

                API.webpack = Lanes::Webpack.server

                threads = Array.new()
                Thread.abort_on_exception = true
                threads << Thread.new { API::Root.run! }
                threads << Thread.new {
                    until API::Root.running?
                        sleep 1
                    end
                    trap("INT") {
                        puts "trapped in subthread"; exit
                        API.webpack.stop!
                    }
                    puts "ok, trap registered"
                }

                API.webpack.start

                # sleep(1)

                unless API.webpack.alive?
                    puts API.webpack.messages
                end

#                puts @@webpack.assets.keys


#                Guard.start

#                API.webpack.wait # stop

                threads.each do |thread|
                    thread.join
                end


            end
        end

    end

end
