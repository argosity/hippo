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
                    ns_name = "#{ns},"
                    ns_ref = "(window.Lanes ? window.Lanes['#{ns}'] : null),"
                    ns_file_ref = "window.Lanes['#{ns}']"
                else
                    ns_name = ""
                    ns_ref = ""
                    ns_file_ref = "window.Lanes"
                end
                file="{namespace:#{ns_file_ref},extensionName:'#{ns}',path:#{path}}"
                "(function(Lanes,#{ns_name}_,LC,React,BS,FILE,window,undefined)"\
                    "{\n#{js}\n})"\
                    "(window.Lanes,#{ns_ref}window.Lanes.Vendor.ld,"\
                    "window.Lanes.Components,"\
                    "window.Lanes.Vendor.React,"\
                    "window.Lanes.Vendor.ReactBootstrap,"\
                    "#{file}, window);"
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
