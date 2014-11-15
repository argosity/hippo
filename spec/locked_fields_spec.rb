require_relative 'spec_helper'

class Customer < Lanes::Model
    def self.attribute_names
        [:terms_id]
    end
end

Lanes::Access::Roles::Support.read << Customer
Lanes::Access::Roles::Administrator.lock Customer, :terms_id

class LockedFieldsTest < Lanes::TestCase

    def setup
        @user = Lanes::User.new( login: 'test', email: 'bob@test.com', name: 'Bob', password: 'testtest')
        @purchaser = Lanes::User.new( login: 'test', email: 'bob@test.com', name: 'Bob', password: 'testtest')
    end

    def test_validations
        @user.role_names = ['support']
        assert_saves @user
        assert @user.can_read?(Customer), "User with support role cannot read Customer"
        refute @user.can_write?(Customer), "User can write, but shouldn't be able to"
        refute @user.can_read?(Customer, :terms_id), "User can read :terms_id but shouldn't be able to"
    end

end
