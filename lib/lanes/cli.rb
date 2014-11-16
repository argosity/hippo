require 'thor'
require_relative '../lanes'
require_relative 'generators/app'
require_relative 'generators/model'
require_relative 'generators/generate'

module Lanes

    class CLI < Thor

        register Generators::App,      'new',      'new [NAME]', 'Creates a new Lanes based application'

        desc "generate SUBCOMMAND ...ARGS", "manage set of tracked repositories"
        subcommand "generate", Generators::Generate

    end

end
