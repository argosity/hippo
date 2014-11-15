require_relative "../spec_helper"

class ApiUserTest < Lanes::ApiTestCase

    def test_query
        get "/users/#{admin.id}.json"
        refute_ok
        login!
        get "/users/#{admin.id}.json"
        assert_ok
        assert_equal admin.id, json_data.id
    end

    def test_create
        login!
        assert_difference ->{User.count}, 1 do
            post "/users.json", {
                login: "nas", name: "Nathan", email: "test@test.com", password: 'testing1234'
            }
            assert_ok
        end
    end

    def test_update_by_self
        user = lanes_users(:support)
        login!(user)
        assert User.can_write_attributes?({id: user.id, :foo=>1}, user)
        put "/users/#{user.id}.json", { name: 'Updated Name', password: 'pass1234', email: 'sam@test.com' }
        assert_ok
        user.reload
        assert_equal 'Updated Name', user.name
        assert_equal 'sam@test.com', user.email
    end

    def test_updating_roles
        login!
        user = lanes_users(:support)
        put "/users/#{user.id}.json", { name: 'Sam', role_names:['administrator'] }
        assert_ok
        user.reload
        assert_equal 'Sam', user.name
        assert_equal ['administrator'], user.role_names
    end

    def test_delete
        login!
        assert_difference ->{User.count}, -1 do
            delete "/users/#{admin.id}.json"
        end
    end

end
