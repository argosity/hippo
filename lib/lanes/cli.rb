require 'thor'
require 'require_all'
require_relative '../lanes'
require_relative 'command'
require_rel 'command/*.rb'

module Lanes

    # This is the main interface to Lanes that is called by the command
    # `bin/lanes`. Do not put any logic in here, create a class and delegate
    # instead.
    class CLI < Thor

        register Command::App, 'new', 'new [NAME]', 'Creates a new Lanes based application'

        desc "generate SUBCOMMAND ...ARGS", "Generate a component"
        subcommand "generate", Command::Generate

        desc "update SUBCOMMAND ...ARGS", "Update a component"
        subcommand "update", Command::Update

        long_desc Command.usage_from_file("server")
        register Command::Server,  'serve', 'serve', 'Run the app in development/testing mode'

        long_desc Command.usage_from_file("db")
        register Command::Db,  'db', 'db', 'Database commands'

        register Command::Console, "console",  "console", "Start IRB console"

    end

end
