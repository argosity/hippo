require_relative 'spec_helper'



class AccessTester < Lanes::Model
    def self.attribute_names
        [:name]
    end
end


class RoleCollectionTest < Lanes::TestCase

    def test_administrator_grants
        user = lanes_users(:admin)
        assert_includes user.role_names, 'administrator'
        assert user.roles.can_read?(AccessTester)
    end
end
