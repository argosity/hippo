module Lanes
    module Command

        class Console < Thor::Group
            include Thor::Actions

            def start
                Command.load_current_extension
                require 'irb'
                require 'irb/completion'
                require 'pp'
                DB.establish_connection
                ActiveRecord::Base.logger = Logger.new STDOUT
                Configuration.apply
                ARGV.clear
                IRB.start
            end

        end
    end
end
