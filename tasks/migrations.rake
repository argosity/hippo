require 'lanes'
require 'active_support/core_ext/string/strip'
require 'fileutils'
## quite a bit of this is cribbed from Sinatra ActiveRecord

load 'active_record/railties/databases.rake'
require 'rake'


namespace :db do

    task :environment do
        Lanes::DB.configure_rake_environment
    end

    desc "create an ActiveRecord migration"
    task :create_migration,[ :name ] do | t, args |
        Lanes::DB.create_migration( "create_skr_" + args[:name] )
    end


end
