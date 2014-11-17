require 'puma/control_cli'
require_relative '../lanes'

desc "Run the puma server in development mode"
task :dev do
    Puma::ControlCLI.new(['start']).run
end

desc "Open an irb session configured with the Lanes environment"
task :console do
    require 'irb'
    require 'irb/completion'
    require 'pp'
    include Lanes
    DB.establish_connection
    ActiveRecord::Base.logger = Logger.new STDOUT
    ARGV.clear
    IRB.start
end
