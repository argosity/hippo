require_relative 'workspace'

module Lanes

    module Access

        class << self

            def _type_to_ref(klass)
                klass.to_s.sub(/^(\w+).*?(\w+)$/,'\1.Models.\2')
            end

            def _type_to_id(klass)
                ( klass.is_a?(Class) ? klass : klass.class ).to_s.demodulize.underscore
            end

            def for_user( user )
                {
                    :roles => user.roles.map{ | role |
                        {
                            type: _type_to_id(role),
                            read: role.read.map{ |klass| _type_to_ref(klass) },
                            write: role.write.map{ |klass| _type_to_ref(klass) },
                            delete: role.delete.map{ |klass| _type_to_ref(klass) }
                        }
                    },
                    :locked_fields => LockedFields.definitions.map{ | klass, locks |
                        {
                            type: _type_to_ref(klass),
                            locks: locks.each_with_object({}) do |(field, grants), result|
                                result[field] = grants.map do |grant|
                                    { role: _type_to_id(grant[:role]), only: grant[:only] }
                                end
                            end
                        }
                    }
                }
            end

        end
    end

end

require_relative 'access/user'
require_relative 'access/authentication_provider'
require_relative 'access/locked_fields'
require_relative 'access/role'
require_relative 'access/role_collection'
require_relative 'access/track_modifications'
require_relative 'access/extension'
