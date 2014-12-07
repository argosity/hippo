require "yui/compressor"
require "closure-compiler"

module Lanes
    module API
        class AssetCompressor < Tilt::Template
            def self.engine_initialized?
                defined?(::YUI)
            end

            def initialize_engine
                require_template_library 'yui/compressor'
                require_template_library 'closure-compiler'
            end

            def prepare
            end

            def js
                # n.b. setting 'ADVANCED_OPTIMIZATIONS' doesn't work at this time, it
                # introduces JS errors :(  Haven't debugged further
                @js||=Closure::Compiler.new
            end
            def css
                @css ||= YUI::CssCompressor.new( :java_opts=>'-client' )
            end
            def evaluate(context, locals, &block)
                case context.content_type
                when 'application/javascript'
                    js.compile(data)
                when 'text/css'
                    css.compress(data)
                else
                    data
                end
            end
        end
    end
end
