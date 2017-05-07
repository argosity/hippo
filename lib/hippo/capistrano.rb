set :linked_files, %w{config/database.yml}

namespace :db do

    desc 'Migrates the database by running: bundle exec hippo db migrate'
    task :migrate => ["deploy:set_rails_env"] do
        on roles(:db) do
            info '[deploy:migrate] Run `hippo db migrate`'
            within release_path do
                with rails_env: fetch(:rails_env) do
                    execute :bundle, "exec hippo db migrate"
                end
            end
        end
    end

    desc 'Seeds the database by running: bundle exec hippo db seed'
    task :seed => ["deploy:set_rails_env"] do
        on roles(:db) do
            info '[deploy:seed] Run `hippo db seed`'
            within release_path do
                with rails_env: fetch(:rails_env) do
                    execute :bundle, "exec hippo db seed"
                end
            end
        end
    end

    after 'deploy:updated', 'db:migrate'
end
