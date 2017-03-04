require 'guard/compat/plugin'
require_relative 'command/puma'

module ::Guard

    class ReloadableSinatra < ::Guard::Plugin
        def start
            puts "RELOAD"
            @puma = ::Lanes::Command::Puma.new
            @puma.start
        end

        def run_on_modifications(paths)
            @puma.stop
            @puma.start
        end

        def stop
            @puma.stop
        end

    end

end
