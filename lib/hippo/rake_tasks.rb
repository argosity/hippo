require 'resque/tasks'
require_relative '../hippo'
require_relative 'command/jest'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = Dir.glob('spec/server/**/*_spec.rb')
  end
rescue LoadError
end

desc "Open an irb session configured with the Hippo environment"
task :console do
    require 'irb'
    require 'irb/completion'
    require 'pp'
    include Hippo
    DB.establish_connection
    ActiveRecord::Base.logger = Logger.new STDOUT
    ARGV.clear
    IRB.start
end

task :env do
    Hippo::DB.configure_rake_environment
    Hippo.config.apply
end

# ## quite a bit of this is cribbed from Sinatra ActiveRecord
load 'active_record/railties/databases.rake'

task :routes do
    require 'hippo/api'
    Hippo::API::Root.routes.each do |verb,handlers|
        puts "\n#{verb}:\n"
        handlers.each do |handler|
            puts handler[0].source.to_s.gsub("\\A",'').gsub("\\z",'')
        end
    end
end

namespace :db do
    task :environment do
        Hippo::DB.configure_rake_environment
    end
    task :load_hippo_config do
        Hippo::DB.configure_rake_environment
    end
    task(:load_config).clear.enhance([:load_hippo_config])
end

namespace :assets do
    task :precompile do
        require 'hippo/command/webpack'
        wp = Hippo::Command::Webpack.new([], compile: true)
        wp.invoke_all
    end
end

task :test => [:spec] do
    ::Hippo::Command::Jest.new.configure.single_run
end

task :lint do
    sh %{node node_modules/eslint/bin/eslint.js --ext .js --ext .jsx client spec/client/}
end

task :ci do
    sh %{bundle exec hippo db migrate}
    sh %{bundle exec hippo db seed}
    sh %{bundle exec hippo jest}
    sh %{bundle exec rspec}
    Rake::Task["lint"].invoke
end

task :crondaily => :env do
    Hippo::Cron.trigger(:daily)
end
