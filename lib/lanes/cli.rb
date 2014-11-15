require 'thor'
require_relative '../lanes'
require_relative 'generators/app'

module Lanes

    class CLI < Thor

        register Generators::App, 'new', 'new [NAME]', 'Creates a new Lanes based application'

    end

end
