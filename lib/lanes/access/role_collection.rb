module Lanes
    module Access

        class RoleCollection
            include Enumerable

            def initialize(user)
                @roles ||= user.role_names.map{ |name|
                    "Lanes::Access::Roles::#{name.classify}".safe_constantize
                }.compact.map{ |klass| klass.new(user) }
            end

            def exposed_data
                @roles.map{ |role| role.class.to_s.demodulize.downcase }
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

            def model_to_class(model)
              model.is_a?(Class) ? model : model.class
            end

            # Test if the given roles grant access to the model
            def test_access(model, attribute, access_type)
                # Check if the attribute is locked
                # If it is, the locks determine access, otherwise use the model's grants
                roles = LockedFields.roles_needed_for(model, attribute, access_type)
                if roles.empty?
                    return !!@roles.detect { |role| yield role }.present?
                else
                    roles.any?{ |role| role.models_include?(model) }
                    #!!roles.find { |role| @roles.map(&:class).include?(role) }
                end
            end

        end

    end
end


require_relative "roles/support"
require_relative "roles/administrator"