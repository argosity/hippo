require 'guard/cli'

require_relative '../extension'
require_relative './jest'

module Hippo
    module Command

        class Guard < Thor::Group
            include Thor::Actions

            def start
                say 'Starting Guard', :green
                Command.load_current_extension
                ::Guard.start
            end
        end
    end
end
