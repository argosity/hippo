module Hippo::Concerns

    # @see ClassMethods
    module AttrAccessorWithDefault
        extend ActiveSupport::Concern

        module ClassMethods

            # defines a attr_accessor with a default value
            # @param name [ Symbol ] name of the attribute
            # @param default [ Object, lambda, Proc ] if a value is given, be aware that it will be shared between instances
            # @example
            #
            #     Shared = Struct.new(:str)
            #     class AttrTestClass
            #         include AttrAccessorWithDefault
            #         attr_accessor_with_default :non_copying, ->{ Shared.new("a default string") }
            #         attr_accessor_with_default :shared, Shared.new("a default string")
            #     end
            #     a = AttrTestClass.new
            #     b = AttrTestClass.new
            #     a.non_copying.str                   #=> "a default string"
            #     a.non_copying.str  = "new_string"   #=> "new string"
            #     b.non_copying.str                   #=> "a default string"
            #
            #     a.shared.str                   #=> "a default string"
            #     b.shared.str                   #=> "a default string"
            #     a.shared.str = "new string"    #=> "new string"
            #     b.shared.str                   #=> "new string"

            def attr_accessor_with_default( name, default=nil )
                attr_writer name
                attr_add_default_setting_method(name)
                attr_reader_with_default(name, default)
            end

            def attr_add_default_setting_method(name)
                module_eval do
                    define_singleton_method(name) do |value = nil|
                        attr_reader_with_default(name, value) if value
                        instance_variable_get("@#{name}".to_sym)
                    end
                end
            end

            def attr_reader_with_default( name, default )
                instance_var = "@#{name.to_s}".to_sym
                instance_variable_set(instance_var, default)
                module_eval do
                    define_method(name) do
                        class << self; self; end.class_eval do
                            attr_reader(name)
                        end
                        if instance_variable_defined?(instance_var)
                            instance_variable_get(instance_var)
                        else
                            instance_variable_set(instance_var,
                                                  default.is_a?(Proc) ?
                                                      instance_exec(&default) : default )
                        end
                    end
                end
            end
        end
    end


end
