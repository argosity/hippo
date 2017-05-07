require_relative 'workspace'

module Hippo

    module Access

        class << self

            def type_to_client(klass)
                klass.to_s.sub(/^(\w+).*?(\w+)$/,'\1.Models.\2')
            end

            def type_to_client_id(klass)
                ( klass.is_a?(Class) ? klass : klass.class ).to_s.demodulize.underscore
            end

            def for_user( user )
                {
                    :roles => user.roles.map{ | role |
                        {
                            type: type_to_client_id(role),
                            read: role.read_types.map{ |klass| type_to_client(klass) },
                            write: role.write_types.map{ |klass| type_to_client(klass) },
                            delete: role.delete_types.map{ |klass| type_to_client(klass) }
                        }
                    },
                    :locked_fields => LockedFields.definitions.map{ | klass, locks |
                        {
                            type: type_to_client(klass),
                            locks: locks.each_with_object({}) do |(field, grants), result|
                                result[field] = grants.map do |grant|
                                    { role: type_to_client_id(grant[:role]), only: grant[:only] }
                                end
                            end
                        }
                    }
                }
            end

        end
    end

end

require_relative 'access/authentication_provider'
require_relative 'access/locked_fields'
require_relative 'access/role'
require_relative 'access/role_collection'
require_relative 'access/track_modifications'
