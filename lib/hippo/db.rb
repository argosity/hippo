module Hippo

    module DB
        extend self

        attr_accessor(:config_file)

        def establish_connection(env=Hippo.config.environment)
            if ENV['DATABASE_URL']
                ::ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
            else
                file = config_file || Extensions.controlling.root_path.join("config","database.yml")
                config = YAML::load( IO.read(file) )
                ::ActiveRecord::Base.configurations = config
                ::ActiveRecord::Base.establish_connection(::ActiveRecord::Base.configurations[env.to_s])
            end
        end

        def load_seed
            path = Pathname.new("./db/seed.rb")
            load path if path.exist?
        end

        def configure_rake_environment
            ActiveRecord::Tasks::DatabaseTasks.seed_loader = Hippo::DB
            default_schema = Extensions.controlling.root_path.join("db","schema.sql")
            ENV['SCHEMA']          ||= default_schema.to_s
            ENV['DB_STRUCTURE']    ||= default_schema.to_s
            ActiveRecord::Base.schema_format = :sql
            ActiveRecord::Base.dump_schema_after_migration = !Hippo.env.production?
            Hippo::DB.establish_connection
            ActiveRecord::Tasks::DatabaseTasks.database_configuration = ActiveRecord::Base.configurations
            env=Hippo.config.environment.to_s
            ActiveRecord::Tasks::DatabaseTasks.env = env
            ActiveRecord::Tasks::DatabaseTasks.migrations_paths = 'db/migrate'
            ActiveRecord::Tasks::DatabaseTasks.current_config(
                config: ActiveRecord::Base.configurations[env]
            )
        end

        private

        def migrations_dir
            ::ActiveRecord::Migrator.migrations_paths.first
        end

        def silence_activerecord
            old_logger = ::ActiveRecord::Base.logger
            ::ActiveRecord::Base.logger = nil
            yield if block_given?
            ::ActiveRecord::Base.logger = old_logger
        end
    end

    ActiveRecord::Base.logger = Hippo.logger

end
