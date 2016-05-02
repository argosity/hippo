module Lanes
    module Access

        class RoleCollection
            include Enumerable

            def initialize(user)
                @role_names = user.role_names
                @roles = user.role_names.map{ |name|
                    "Lanes::Access::Roles::#{name.classify}".safe_constantize
                }.compact.map{ |klass| klass.new(user) }
            end

            def exposed_data
                @role_names
            end

            # @param role [String]
            # @return [Boolean] Does a role with the given id exist?
            def include?(role)
                @role_names.include?(role)
            end

            # @param model [Lanes::Model]
            # @param attribute [Symbol]
            # @return [Boolean] Can the User view the model?
            def can_read?(model, attribute = nil)
                klass=model_to_class(model)
                test_access(klass, attribute, :read){ |role| role.can_read?(klass) }
            end

            # @param model [Lanes::Model]
            # @param attribute [Symbol]
            # @return [Boolean] Can the User create and update the model?
            def can_write?(model, attribute = nil)
                klass=model_to_class(model)
                test_access(klass, attribute, :write){ |role| role.can_write?(klass) }
            end

            # @param model [Lanes::Model]
            # @param id  [Fixnum] the id of the record to remove
            # @return [Boolean] Can the User delete the model?
            def can_delete?(model,id)
                klass=model_to_class(model)
                @roles.each{ |role| role.can_delete?(klass) }
            end

            # @return [Array<symbol>] list of roles
            def to_sym
                @roles.map{ |r| r.class.to_s.demodulize.downcase.to_sym }
            end

            def each
                @roles.each{|r| yield r}
            end

          private

            def role_types
                @role_types ||= @roles.map(&:class)
            end

            def model_to_class(model)
                model.is_a?(Class) ? model : model.class
            end

            # Test if the given roles grant access to the model
            def test_access(model, attribute, access_type)
                # Check if the attribute is locked
                # If it is, the locks determine access, otherwise use the model's grants
                locked_to_roles = LockedFields.roles_needed_for(model, attribute, access_type)
                if locked_to_roles.none?
                    return @roles.detect{ |role| yield role }.present?
                else
                    role_types.any?{|role| role.can_access_locked_roles?(locked_to_roles) }
                end
            end

        end

    end
end


require_relative "roles/support"
require_relative "roles/administrator"
