require 'bundler/setup'
require "bundler/gem_tasks"
require 'rake/testtask'
require 'yard'
require 'yard-activerecord'
require_relative 'yard_ext/all'
require 'guard'
require 'lanes/rake_tasks'
require 'knitter'
Dir.glob('tasks/*.rake').each { |r| load r}

Rake::TestTask.new do |t|
    t.libs << 'test'
    t.pattern = "test/*_test.rb"
end


YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/skr/concerns/*.rb','lib/**/*.rb','db/schema.rb']
    t.options = ["--title=Stockor Core Documentation",
                 "--markup=markdown",
                 "--template-path=yard_ext/templates",
                 "--readme=README.md"]
end


task :doc => 'db:environment' do
    ENV['SCHEMA']       = 'db/schema.rb'
    ENV['DB_STRUCTURE'] = 'db/schema.rb'
    Rake::Task["db:schema:dump"].invoke
    Rake::Task["yard"].invoke
end
