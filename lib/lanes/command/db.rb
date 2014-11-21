require 'rake'
require 'find'

module Lanes
    module Command

        class Db < Thor

            desc 'migrate', 'Run database migrations for all loaded extensions'
            def migrate
                run_task "db:migrate"
            end

            desc "seed", "seed the database with data from all extensions"
            def seed
                run_task "db:seed"
            end

          private

            def run_task(task)
                Command.load_current_extension
                require_relative "../rake_tasks"
                Extensions.each do |ext|
                    Dir.chdir(ext.root_path) do
                        Rake::Task[task].invoke
                    end
                end
            end

        end
    end
end
