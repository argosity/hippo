require 'thor'
require 'require_all'
require_relative '../hippo'
require_relative 'command'
require_relative 'command/named_command'
require_rel 'command/*.rb'

module Hippo

    # This is the main interface to Hippo that is called by the command
    # `bin/hippo`. Do not put any logic in here, create a class and delegate
    # instead.
    class CLI < Thor

        register Command::App, 'new', 'new [NAME]', 'Creates a new Hippo based application'

        desc "generate SUBCOMMAND ...ARGS", "Generate a component"
        subcommand "generate", Command::Generate

        desc "update SUBCOMMAND ...ARGS", "Update a model"
        subcommand "update", Command::Update

        desc "version", "Display version of hippo"
        def version
            puts Hippo::VERSION
        end

        long_desc Command.usage_from_file("server")
        register Command::Server,  'serve', 'serve', 'Run the app in development/testing mode'

        long_desc "start the Jest test server"
        register Command::Jest,  'jest', 'jest', 'Start the Jest test server for client code'

        long_desc "start the webpack dev server"
        register Command::Webpack, 'webpack', 'webpack', 'Start the Webpack Dev Server'

        long_desc "start the Puma server"
        register Command::Puma, 'puma', 'puma', 'Start the Puma(Sinata) Server'

        long_desc "start the guard test runner"
        register Command::Guard,  'guard', 'guard', 'Start the Guard server'

        long_desc Command.usage_from_file("db")
        register Command::Db,  'db', 'db', 'Database commands'

        register Command::Console, "console",  "console", "Start IRB console"

    end

end
