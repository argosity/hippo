module Lanes

    module DB
        extend self

        attr_accessor(:config_file)

        def establish_connection( env = ENV['RAILS_ENV'] || 'development')
            if ENV['DATABASE_URL']
                ::ActiveRecord::Base.establish_connection( ENV['DATABASE_URL'] )
            else
                file = config_file || Extensions.controlling.root_path.join("config","database.yml")
                config = YAML::load( IO.read(file) )
                ::ActiveRecord::Base.configurations = config
                ::ActiveRecord::Base.establish_connection( ::ActiveRecord::Base.configurations[ env ] )
            end
        end

        def load_seed
            path = Pathname.new("./db/seed.rb")
            load path if path.exist?
        end

        def configure_rake_environment
            ActiveRecord::Tasks::DatabaseTasks.seed_loader = Lanes::DB
            env = ENV['RAILS_ENV'] || 'development'
            ENV['SCHEMA']          ||= 'db/schema.sql'
            ENV['DB_STRUCTURE']    ||= 'db/schema.sql'
            ActiveRecord::Base.schema_format = :sql
            Lanes::DB.establish_connection( env )
            ActiveRecord::Tasks::DatabaseTasks.database_configuration = ActiveRecord::Base.configurations
            ActiveRecord::Tasks::DatabaseTasks.env = 'test'
            ActiveRecord::Tasks::DatabaseTasks.migrations_paths = 'db/migrate'
            ActiveRecord::Tasks::DatabaseTasks.current_config( :config => ActiveRecord::Base.configurations[ env ] )
        end


        private

        def migrations_dir
            ::ActiveRecord::Migrator.migrations_paths.first
        end

        def silence_activerecord(&block)
            old_logger = ::ActiveRecord::Base.logger
            ::ActiveRecord::Base.logger = nil
            yield if block_given?
            ::ActiveRecord::Base.logger = old_logger
        end
    end
end
