module Hippo
    module Access

        class Role
            class_attribute :read_types, :write_types, :delete_types

            def initialize(user)
                @user = user
            end

            def can_read?(model)
                read_types.include?(model)
            end

            def can_write?(model)
                write_types.include?(model)
            end

            def can_delete?(model)
                delete_types.include?(model)
            end

            class << self
                ALL=Array.new

                def grant_global_access(types=:all, *klass)
                    unless types.is_a?(Symbol)
                        klass.unshift(types)
                        types=:all
                    end
                    types = [:read,:write,:delete] if :all == types
                    types = [*types]
                    ALL.each do | child |
                        types.each{ |type| child.send(type).concat(klass) }
                    end
                end

                def inherited(subklass)
                    ALL << subklass
                    subklass.read_types = []; subklass.write_types = []; subklass.delete_types = []
                end

                def grant( *klasses )
                    read_types.push(*klasses)
                    write_types.push(*klasses)
                    delete_types.push(*klasses)
                end

                def read( *klasses )
                    read_types.push(*klasses)
                end

                def write( *klasses )
                    write_types.push(*klasses)
                end

                def delete(*klasses )
                    delete_types.push(*klasses)
                end

                def lock(klass, *attributes)
                    attributes.each do | attr |
                        LockedFields.lock(klass, attr, self)
                    end
                end

                def lock_writes(klass, *attributes)
                    attributes.each do | attr |
                        LockedFields.lock(klass, attr, self, :write)
                    end
                end

                def all_available
                    ALL
                end

                # By default a role can only access if it's type is included in the
                # array of acceptable roles.  An Admin role may provide a custom implementation
                def can_access_locked_roles?(roles)
                    roles.include?(self)
                end
            end
        end

    end
end
