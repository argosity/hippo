# Coffeescript has two shortcomings with regards to Lanes
#
# The first is that it's extends format is incompatible with AmpersandState,
# State does quite a bit more via it's own .extend methods.
# Accordingly, we substitute our own "extend" call whenever we encounter a coffeescript extends
#
# The second issue is that if a constructor isn't present, coffeescript with generate it's own
# blank implementation that fails to call "super".  We add a constructor that does call super if one's missing.

module Lanes
    module API
        class CoffeeScriptProcessor < JsAssetCompiler

            class CoffeeClass
                attr_reader :name, :extends, :contents, :file_contents, :indent
                def initialize(name, extends, file_contents)
                    @name=name; @extends=extends; @file_contents=file_contents
                    file_contents.gsub!(/class\s+#{name}\s+.*?\n/,"class #{name}\n")
                    @contents = @file_contents[/(class #{name}\n.*?)(\n\w|\Z)/m,1]
                    @indent = @contents[/\n(\s+)(\w+):/,1] || '    '
                end

                def ensure_property(property_name, definition)
                    if contents !~ /^\s+#{property_name}\s*:/
                        # figure out how much to indent, sigh.
                        file_contents.gsub!(/class #{name}\n/,
                                            "\\0#{indent}#{property_name}: #{definition}\n")
                    end
                end

                def save
                    file_contents.gsub!( /(class #{name}\n.*?)(\n\w|\Z)/m,
                                         "\\1\n#{extends}.extend(#{name})\n\\2" )
                end
            end

            self.registered_extension = '.coffee'

            attr_reader :contents

            CONSTRUCTOR = /constructor\s*:/

            EXTENDING_CLASS_DEFINITION = /class\s+([\w|\.]+)\s+extends\s+([\w|\.]+)\s*?\n/

            def cleaned
                @contents = data.dup
                data.scan(EXTENDING_CLASS_DEFINITION) do |match|
                    (name, extends) = match
                    cc = CoffeeClass.new(name, extends, contents)
                    cc.ensure_property("constructor", "-> super")
                    cc.ensure_property("FILE", "FILE")
                    cc.save
                end
                contents
            end

            def evaluate(scope, locals, &block)
                wrap_js scope, ::CoffeeScript.compile(cleaned, bare: true)
            end


        end
    end
end
