require 'puma/control_cli'
require 'resque/tasks'
require_relative '../lanes'
require_relative 'command/jest'

desc "Run the puma server in development mode"
task :dev do
    Puma::ControlCLI.new(['start']).run
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = Dir.glob('spec/server/**/*_spec.rb')
  end
rescue LoadError
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

task :env do
    Lanes::DB.configure_rake_environment
    Lanes::Configuration.apply
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
    task :load_lanes_config do
        Lanes::DB.configure_rake_environment
    end
    task(:load_config).clear.enhance([:load_lanes_config])
end

namespace :assets do
    task :precompile do
        require 'lanes/command/webpack'
        wp = Lanes::Command::Webpack.new([], compile: true)
        wp.invoke_all
    end
end

task :test => [:spec] do
    ::Lanes::Command::Jest.new.configure.single_run
end

task :ci => ['db:migrate', 'db:seed'] do
    sh %{node node_modules/eslint/bin/eslint.js client spec/client/}
    sh %{bundle exec lanes jest}
    sh %{bundle exec rspec}
end
