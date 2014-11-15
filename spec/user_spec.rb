require_relative 'spec_helper'

describe Lanes::User do

    before do
        @user = Lanes::User.new( login: 'test', email: 'bob@test.com', name: 'Bob', password: 'testtest')
    end

    it "validates attributes" do
        user = Lanes::User.new
        refute_saves user, 'login'
        user.assign_attributes login: 'test', email: 'bob', name: 'Bob'
        refute_saves user, 'email'
        user.email = 'bob@test.com'
        refute_saves user, 'password'
        user.password = 'password'
        assert_saves user
    end

    it "sets roles" do
        @user.role_names = ['administrator']
        assert_saves @user
        assert_equal [ 'administrator' ], @user.role_names
    end

    it "can has built-in roles" do
        @support = Lanes::User.new( login: 'test', email: 'support@test.com', name: 'support Bob',
          password: 'testtest', role_names:['support'])
        @admin = Lanes::User.new( login: 'test', email: 'admin@test.com', name: 'admin Bob',
          password: 'testtest', role_names:['administrator'])

        assert @admin.can_read?(@support)
        assert @admin.can_write?(@support)

        assert @support.can_read?(@admin)
        refute @support.can_write?(@admin)
    end

    it "can be set from attribute data" do
        attrs = { login: 'test', email: 'bob', name: 'Bob', password:'password' }
        assert_equal attrs, @user.set_attribute_data( attrs, lanes_users(:admin) )
    end

    it "users can update themselves" do
        user  = lanes_users(:support)
        admin = lanes_users(:admin)
        attrs = { id: 34, login: 'test', email: 'bob', name: 'Bob', password:'password' }
        assert_empty admin.set_attribute_data( attrs, user )
        attrs[:id] = user.id
        assert_equal( {email: 'bob', name: 'Bob', password:'password'}, user.set_attribute_data(attrs, user) )
    end

end
