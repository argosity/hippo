# Coffeescript has two shortcomings with regards to Lanes
#
# The first is that it's extends format is incompatible with AmpersandState,
# State does quite a bit more via it's own .extend methods.
# Accordingly, we substitute our own "extend" call whenever we encounter a coffeescript extends
#
# The second issue is that if a constructor isn't present, coffeescript with generate it's own
# blank implementation that fails to call "super".  We add a constructor that does call super if one's missing.

require 'coffee-react'

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

                def setup_properties
                    ensure_property("constructor", "-> super")
                    ensure_property("FILE", "FILE")
                end

                def save
                    file_contents.gsub!(/^(\s*class #{name}\n.*?)(\n\w|\Z)/m,
                                        "\\1\n#{extends}.extend(#{name})\n\\2")
                end
            end

            class ReactCoffeeClass < CoffeeClass

                def setup_properties
                    ensure_property("FILE", "FILE")
                    ensure_property("displayName", "'#{@name}'")
                end

                def save
                    file_contents.gsub!( /^(\s*class #{name}\n.*?)(\n\w|\Z)/m,
                                         "\\1\n#{name} = #{extends}.extend(#{name})\n\\2" )
                end
            end


            self.registered_extension = '.coffee'

            attr_reader :contents

            CONSTRUCTOR = /constructor\s*:/

            EXTENDING_CLASS_DEFINITION = /^\s*class\s+([\w|\.]+)\s+extends\s+([\w|\.]+)\s*?(\n|\#)/

            def cleaned
                @contents = data.dup
                data.scan(EXTENDING_CLASS_DEFINITION) do |match|
                    (name, extends) = match
                    cc = if extends =~ /\.(React|Screens|Components)\./
                             ReactCoffeeClass.new(name, extends, contents)
                         else
                             CoffeeClass.new(name, extends, contents)
                         end
                    cc.setup_properties
                    cc.save
                end
                contents
            end


            def evaluate(scope, locals, &block)
                wrap_js scope, ::CoffeeScript.compile(cleaned, bare: true)
            end
        end

        class CjsxProcessor < CoffeeScriptProcessor

            self.registered_extension = '.cjsx'

            def evaluate(scope, locals, &block)
                begin
                    coffee = CoffeeReact.transform(cleaned)
                    js = ::CoffeeScript.compile(coffee, bare: true)
                    wrap_js scope, js
                rescue => e
                    Lanes.logger.warn e
                    Lanes.logger.warn cleaned
                    raise e
                end
            end

        end
    end
end
