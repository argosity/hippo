require 'liquid'
require_rel 'liquid/*.rb'

module Hippo

    module Templates

        class Liquid < Base

            def extension
                '.liquid'
            end

            def render
                template.render(variables.stringify_keys)
            end

            def template
                @template ||= ::Liquid::Template.parse(source, :error_mode => :warn)
            end

        end

    end
end
