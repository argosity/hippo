module Lanes

    module Access

        class << self

            def _type_to_str(klass)
                klass.to_s.demodulize.underscore
            end

            def for_user( user )
                {
                    :roles => user.roles.map{ | role |
                        {
                            type: _type_to_str(role.class),
                            read: role.read.map{ |klass| _type_to_str(klass) },
                            write: role.write.map{ |klass| _type_to_str(klass) },
                            delete: role.delete.map{ |klass| _type_to_str(klass) }
                        }
                    },
                    :locked_fields => LockedFields.definitions.map{ | klass, locks |
                        {
                            type: _type_to_str(klass),
                            locks: locks.each_with_object({}) do |(field, grants), result|
                                result[field] = grants.map do |grant|
                                    { role: _type_to_str(grant[:role]), only: grant[:only] }
                                end
                            end
                        }
                    }
                }
            end

            def calculate_model_access!
                Roles::Administrator.grant_global_access!
            end


        end
    end

end

require_relative 'access/locked_fields'
require_relative 'access/role'
require_relative 'access/role_collection'

Lanes::Access.calculate_model_access!
#    require_relative 'access/user_maint_screen'
#    require_relative 'access/workspace_extension'
