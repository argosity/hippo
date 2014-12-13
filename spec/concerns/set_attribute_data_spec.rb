require "lanes/spec_helper"

class SetAttributeDataTest < Lanes::TestCase

    include TestingModels
    def setup
        @user = DummyUser.new
    end

    def test_attribute_access
        tm = TestModel.new
        assert tm.setting_attribute_is_allowed?(:name, @user), "can't access :name"
        assert tm.can_write_attributes?({}, @user), "Can't write to TestModel"
        data = { name: 'CASH', number: '1200' }
        assert_equal( data, TestModel.new.set_attribute_data(data,@user) )
    end

    def test_blacklisting
        assert TestModel.new.setting_attribute_is_allowed?(:number,@user)
        TestModel.send :blacklist_attributes, :number
        assert_includes TestModel.blacklisted_attributes, :number
        refute TestModel.new.setting_attribute_is_allowed?(:number, @user), "Allowed setting blacklisted attribute"
        record = TestModel.from_attribute_data({ name: 'CASH', number: '1234'}, @user)
        assert_nil record.number
    end

    def test_whitelisting
        refute TestModel.new.setting_attribute_is_allowed?('updated_at', @user)
        TestModel.send :whitelist_attributes, :updated_at
        assert TestModel.new.setting_attribute_is_allowed?('updated_at', @user)
    end

    def test_recursive_cleaning_has_many
        assert TestModel.has_exported_association?( :hm, @user )
        data = {
            name: 'testing',
            hm: [
              { description: 'childish-1', secret_field: 'dr evil' },
              { description: 'childish-2', secret_field: 'dr evil' }
          ]}
        record = TestModel.new
        cleaned_data = record.set_attribute_data(data,@user)
        assert_equal 2, record.hm.length
        assert_equal cleaned_data, {:name=>"testing", :hm=>[{:description=>"childish-1"}, {:description=>"childish-2"}]}
        assert_saves record
    end

    def test_sending_to_method
        tm = TestModel.new
        def tm.meaning_of_life=(var); @setting = var end
        tm.set_attribute_data({ meaning_of_life: 42 }, @user)
        assert_nil tm.instance_variable_get(:@setting)
        TestModel.send :whitelist_attributes, :meaning_of_life
        tm.set_attribute_data({ meaning_of_life: 42 }, @user)
        assert_equal 42, tm.instance_variable_get(:@setting)
    end

end
