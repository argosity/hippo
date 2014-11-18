require 'thor'
require_relative '../lanes'
require_relative 'command/app'
require_relative 'command/model'
require_relative 'command/generate'

module Lanes

    class CLI < Thor

        register Command::App,      'new',      'new [NAME]', 'Creates a new Lanes based application'

        desc "generate SUBCOMMAND ...ARGS", "Generate a component"
        subcommand "generate", Command::Generate

    end

end
