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

# ## quite a bit of this is cribbed from Sinatra ActiveRecord
load 'active_record/railties/databases.rake'

task :routes do
    require 'lanes/api'
    Lanes::API::Root.routes.each do |verb,handlers|
        puts "\n#{verb}:\n"
        handlers.each do |handler|
            puts handler[0].source.to_s.gsub("\\A",'').gsub("\\z",'')
        end
    end
end

namespace :db do
    task :environment do
        Lanes::DB.configure_rake_environment
    end
end

namespace :assets do
    task :precompile do
        require_relative 'api/sprockets_extension'
        Lanes::API::SprocketsExtension.compile!
    end
end
