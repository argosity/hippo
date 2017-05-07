require 'guard/compat/plugin'
require_relative './command/webpack_view'

module ::Guard
    class ReloadableView < ::Guard::Plugin
        def run_on_modifications(paths)
            paths.each do |view|
                ::Hippo::Command::WebpackView.new(view).write
                Hippo.logger.info "Re-compiled #{view}"
            end
        end
    end
end
