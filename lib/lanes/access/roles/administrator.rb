module Lanes
    module Access

        module Roles

            class Administrator < Role

                def self.grant_global_access!

                    self.grant( *Lanes::Model.descendants )

                    LockedFields.definitions.each do | klass, fields |
                        fields.each do |field, grants|
                            grants.push({ role: self, only: nil })
                        end
                    end
                end


                def can_read?(model)
                    true
                end

                def can_write?(model)
                    true
                end

                def can_delete?(model)
                    true
                end

                lock User, :password_digest

            end

        end

    end
end
