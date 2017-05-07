require 'guard/cli'

require_relative '../extension'
require_relative './jest'

module Hippo
    module Command

        class Guard < Thor::Group
            include Thor::Actions

            def start
                say 'Starting Guard', :green
                ::Guard.start
            end
        end
    end
end
