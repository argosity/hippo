module Lanes
    module Access

        class Role
            class_attribute :read, :write, :delete

            def initialize(user)
                @user = user
            end

            def can_read?(model)
                read.include?(model)
            end

            def can_write?(model)
                write.include?(model)
            end

            def can_delete?(model)
                delete.include?(model)
            end

            class << self
                ALL=Array.new

                def grant_global_access(types=[:read,:write,:delete], *klass)
                    types = [*types]
                    ALL.each do | child |
                        types.each{ |type| child.send(type).concat(klass) }
                    end
                end

                def inherited(subklass)
                    ALL << subklass
                    subklass.read = []; subklass.write = []; subklass.delete = []
                end

                def grant( *klasses )
                    self.read.push( *klasses )
                    write.push( *klasses )
                    delete.push( *klasses )
                end

                def read( *klasses )
                    self.read.push( *klasses )
                end

                def write( *klasses )
                    self.write.push( *klasses )
                end

                def delete( *klasses )
                    self.delete.push( *klasses )
                end

                def lock(klass, attribute)
                    LockedFields.lock( klass, attribute, self)
                end

                def lock_writes(klass, attribute)
                    LockedFields.lock( klass, attribute, self, :write)
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
