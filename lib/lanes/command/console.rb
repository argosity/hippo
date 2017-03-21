module Lanes
    module Command

        class Console < Thor::Group
            include Thor::Actions

            def start
                ext = Command.load_current_extension
                require 'irb'
                require 'irb/completion'
                require 'pp'
                DB.establish_connection
                ActiveRecord::Base.logger = Logger.new STDOUT
                Configuration.apply
                ext.on_dev_console
                ARGV.clear
                IRB.start
            end

        end
    end
end
