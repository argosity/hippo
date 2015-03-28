set :linked_files, %w{config/database.yml}

namespace :db do

    desc 'Migrates the database by running: bundle exec lanes db migrate'
    task :migrate => ["deploy:set_rails_env"] do
        on roles(:db) do
            info '[deploy:migrate] Run `lanes db migrate`'
            within release_path do
                with rails_env: fetch(:rails_env) do
                    execute :bundle, "exec lanes db migrate"
                end
            end
        end
    end

    desc 'Seeds the database by running: bundle exec lanes db seed'
    task :seed => ["deploy:set_rails_env"] do
        on roles(:db) do
            info '[deploy:seed] Run `lanes db seed`'
            within release_path do
                with rails_env: fetch(:rails_env) do
                    execute :bundle, "exec lanes db seed"
                end
            end
        end
    end

    after 'deploy:updated', 'db:migrate'
end
