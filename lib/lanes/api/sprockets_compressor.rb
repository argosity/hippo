require "yui/compressor"

module Lanes
    module API
        class AssetCompressor < Tilt::Template
            def self.engine_initialized?
                defined?(::YUI)
            end

            def initialize_engine
                require_template_library 'yui/compressor'
            end

            def prepare
            end

            def js
                @js||=YUI::JavaScriptCompressor.new(:munge => true, :java_opts=>'-client')
            end
            def css
                @css ||= YUI::CssCompressor.new( :java_opts=>'-client' )
            end
            def evaluate(context, locals, &block)
                case context.content_type
                when 'application/javascript'
                    js.compress(data)
                when 'text/css'
                    css.compress(data)
                else
                    data
                end
            end
        end
    end
end
