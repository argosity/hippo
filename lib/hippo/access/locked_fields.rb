module Hippo
    module Access

        class LockedFields

            @definitions = Hash.new{ |fields,klass|
                fields[klass] = Hash.new{ |grants,field| grants[field] = [] }
            }
            class << self

                # @param klass [Hippo::Model]
                # @param field [Symbol]
                # @param access_type [:read, :write]
                # @return [Array<Role>] Roles that are allowed to access the field.
                # An empty array indicates that the field is not locked and the Model
                # should be used for determining access
                def roles_needed_for(klass, attribute, access_type)
                    if @definitions.has_key?(klass) && @definitions[klass].has_key?(attribute)
                        @definitions[klass][attribute].each_with_object([]) do | grant, result |
                            result.push(grant[:role]) if grant[:only].nil? || grant[:only] == access_type
                        end
                    else
                        []
                    end
                end

                # Lock a given class and attribute to a given role
                # @param klass [Hippo::Model]
                # @param field [Symbol]
                # @param only [:read, :write]
                def lock(klass, field, role, only=nil)
                    @definitions[klass][field] << { role: role, only: only }
                end

                def definitions
                    @definitions
                end
            end

        end

    end
end
