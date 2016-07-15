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

            def get_js_aliases(ns)
                ext = Extensions.for_identifier(ns)
                aliases = ext ? ext.client_js_aliases || {} : {}
                aliases.merge!({
                    'LC'    => 'window.Lanes.Components',
                    'React' => 'window.Lanes.Vendor.React',
                    'BS'    => 'window.Lanes.Vendor.ReactBootstrap'
                 })
                [ aliases.keys.join(','), aliases.values.join(',') ]
            end

            def get_wrapping_vars(identifier)
                if identifier
                    ns = identifier.underscore.camelize
                else
                    ns = ''
                    identifier = ''
                end
                if identifier == "lanes"
                    ns_file_ref = "window.Lanes"
                    ns_ref = ''
                    ns_name = ''
                else
                    ns_name = "#{ns},"
                    ns_ref = "(window.Lanes ? window.Lanes['#{ns}'] : null),"
                    ns_file_ref = "window.Lanes['#{ns}']"
                end
                return ns, ns_file_ref, ns_ref, ns_name
            end

            def wrap_js(scope, js)
                dirs = scope.logical_path.split(File::SEPARATOR)
                identifier   = dirs.many? ? dirs.first : nil
                path = "[" + dirs.map{|d| "\"#{d}\"" }.join(",") + "]"
                # if the file is being loaded under the "lanes" directory
                # it's not an extension
                (aliases, definitions) = get_js_aliases(identifier)
                ns, ns_file_ref, ns_ref, ns_name = get_wrapping_vars(identifier)
                file="{namespace:#{ns_file_ref},extension:{name:'#{ns}',identifier:'#{identifier}'},path:#{path}}"
                "(function(Lanes,#{ns_name}_,#{aliases},FILE,window,undefined)"\
                    "{\n#{js}\n})"\
                    "(window.Lanes,#{ns_ref}window.Lanes.Vendor.ld,"\
                    "#{definitions},#{file},window);"
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
