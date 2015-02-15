set :linked_dirs, %w{config}

namespace :deploy do

    desc 'Runs bundle exec lanes db migrate'
    task :migrate => [:set_rails_env] do
        on primary fetch(:migration_role) do
            info '[deploy:migrate] Run `lanes db migrate`'
            within release_path do
                with rails_env: fetch(:rails_env) do
                    execute :bundle, "exec lanes db migrate"
                end
            end
        end
    end

    after 'deploy:updated', 'deploy:migrate'
end
