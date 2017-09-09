require 'bundler/setup'
require "bundler/gem_tasks"
require 'yard'
require 'yard-activerecord'
require_relative 'yard_ext/all'
require 'guard'
require 'hippo/rake_tasks'
require 'knitter'
require "bump/tasks"

Dir.glob('tasks/*.rake').each { |r| load r}

YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/skr/concerns/*.rb','lib/**/*.rb','db/schema.rb']
    t.options = ["--title=Stockor Core Documentation",
                 "--markup=markdown",
                 "--template-path=yard_ext/templates",
                 "--readme=README.md"]
end

task :npmrelease do
    sh "npm publish"
end

task :release => :npmrelease

task :doc => 'db:environment' do
    ENV['SCHEMA']       = 'db/schema.rb'
    ENV['DB_STRUCTURE'] = 'db/schema.rb'
    Rake::Task["db:schema:dump"].invoke
    Rake::Task["yard"].invoke
end
