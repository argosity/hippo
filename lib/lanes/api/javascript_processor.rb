require 'execjs'
require 'coffee-script'
require 'open3'

module Lanes
    module API

        TranspileError = Class.new(StandardError)

        class JsAssetCompiler < Tilt::Template
            class_attribute :registered_extension
            def prepare
                # NOOP
            end
            def self.register(env)
                self.descendants.each do | klass |
                    klass.default_mime_type = 'application/javascript'
                    env.register_engine( klass.registered_extension, klass )
                end
            end

            def wrap_js(scope, js)
                dirs = scope.logical_path.split(File::SEPARATOR)
                ns   = dirs.many? ? dirs.first.camelize : nil
                path = "[" + dirs.map{|d| "\"#{d}\"" }.join(",") + "]"
                # if the file is being loaded under the "lanes" directory
                # it's not an extension
                if ns && ns != "Lanes"
                    ns = ns.underscore.camelize
                    ref = "(window.Lanes ? window.Lanes['#{ns}'] : null)"
                    "(function(Lanes, #{ns}, _, window, FILE, undefined)"\
                      "{\n#{js}\n})(window.Lanes,#{ref},window._, window,"\
                      "{namespace:#{ref},extensionName:'#{ns}',path:#{path}});"
                else
                    "(function(Lanes, _, window, FILE, undefined)"\
                      "{\n#{js}\n})(window.Lanes,window._, window,"\
                      "{namespace:window.Lanes,extensionName:'Lanes',path:#{path}});"
                end
            end

        end

        # class CoffeeScriptWrapper < JsAssetCompiler
        #     self.registered_extension = '.coffee'

        #     CONSTRUCTOR = /constructor\s*:/
        #     CLASS_DEFINITION = /\s*class\s+([\w|\.]+)/
        #     EXTENDING_CLASS = /class\s+([\w|\.]+)\s+extends\s+([\w|\.]+)\s*?\n/

        #     # Coffeescript has two shortcomings with regards to Lanes
        #     #
        #     # The first is that it's extends format is incompatible with AmpersandState,
        #     # State does quite a bit more via it's own .extend methods.
        #     # Accordingly, we substitute our own "extend" call whenever we encounter a coffeescript extends
        #     #
        #     # The second issue is that if a constructor isn't present, coffeescript with generate it's own
        #     # blank implementation that fails to call "super".  We add a constructor that does call super if one's missing.

        #     def cleaned
        #         contents = data.dup
        #         data.scan(CLASS_DEFINITION) do |match|
        #             (name, extends) = match
        #             definition = get_definition(name)


        #             # is it missing a constructor?
        #             if definition !~ /constructor:/
        #                 # figure out how much to indent, sigh.
        #                 indent = definition[/\n(\s+)(\w+):/,1] || '    '
        #                 contents.gsub!(/class #{name}\n/,"\\0#{indent}constructor: -> super\n")

        #             end
        #             contents.gsub!( /(class #{name}\n.*?)(\n\w|\Z)/m, "\\1\n#{extends}.extend(#{name})\n\\2" )

        #             contents
        #             #contents << "#{extends}.extend(#{name})\n"
        #         end
        #         contents
        #     end

        #     def evaluate(scope, locals, &block)
        #         wrap_js scope, ::CoffeeScript.compile(cleaned, bare: true)
        #     end

        #     def get_definition(name)
        #         contents.gsub!(/class\s+#{name}\s+.*?\n/,"class #{name}\n")
        #                        definition = contents[/(class #{name}\n.*?)(\n\w|\Z)/m,1]
        #     end
        # end

        class Es6Compiler < JsAssetCompiler
            self.registered_extension = '.es6'
            def evaluate(scope, locals, &block)
                cmd = "#{Lanes.config.es6_transpiler_path} #{Lanes.config.es6_transpiler_options}"
                stdout, stderr, _status = Open3.capture3(cmd, stdin_data: data)
                if stderr.empty?
                    wrap_js scope, stdout
                else
                    raise TranspileError, stderr
                end
            end
        end

        class JSWrapper < JsAssetCompiler
            self.registered_extension = '.lanes'
            def evaluate(scope, locals, &block)
                wrap_js scope, data
            end
        end

        class LanesTemplates < JsAssetCompiler
            self.registered_extension = '.html'
            def evaluate(scope, locals, &block)
                "Lanes.Templates['#{scope.logical_path}']=" + self.compile(data)
            end

            def contents
                @contents ||= Pathname.new(__FILE__).dirname.join('eco.js').read
            end

            def combined_contents
                [CoffeeScript::Source.contents, contents].join(";\n")
            end

            def context
                @context ||= ExecJS.compile(combined_contents)
            end

            def compile(template)
                template = template.read if template.respond_to?(:read)
                context.call("eco.precompile", template, 'Lanes.Templates.Wrapper','Lanes.Views.Helpers')
            end

        end

    end
end

require_relative 'coffeescript_processor'
