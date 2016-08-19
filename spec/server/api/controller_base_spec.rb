require_relative "../spec_helper"
require 'lanes/access/user'

class ControllerBaseSpec < Lanes::TestCase

    include TestingModels

    def test_record_retrieval
        1.upto(10){|i| TestModel.create!(id: i, name:'test') }
        controller = Lanes::API::ControllerBase.new(TestModel,
                                                    Lanes::API::AuthenticationProvider.new({}),
                                                    {id: 1})
        assert_equal(controller.send(:perform_retrieval), {
                         :success=>true, :message=>"Retrieve succeeded",
                         :data=>{"id"=>1, "bt_id"=>nil, "name"=>"test", "number"=>nil}
                     })
    end

    def test_single_update
        TestModel.create!(id: 1, name:'Joe')
        controller = Lanes::API::ControllerBase.new(TestModel,
                                                    Lanes::API::AuthenticationProvider.new({}),
                                                    {id: 1}, {name:'Bob'})
        assert_equal(controller.send(:perform_single_update), {
                         :success=>true, :message=>"Update succeeded",
                         :data=>{"id"=>1, "bt_id"=>nil, "name"=>"Bob", "number"=>nil}
                     })
        assert_equal TestModel.where(id: 1).first.name, 'Bob'
    end

    def test_multiple_updates
        TestModel.create!(id: 1, name:'Joe')
        TestModel.create!(id: 2, name:'Bob')
        def TestModel.access_limits_for_query(query, user, params)
            query.where(name:'Joe')
        end
        controller = Lanes::API::ControllerBase.new(TestModel,
                                                    Lanes::API::AuthenticationProvider.new({}),
                                                    {},
                                                    [{'id'=>1}, {'id'=>2}])

        assert_equal( controller.send(:perform_multiple_updates), {
                          :success=>true,
                          :message=>"Update succeeded",
                          :data=>[{"id"=>1, "bt_id"=>nil, "name"=>"Joe", "number"=>nil}]
        })
    end

    def test_single_destroy
        TestModel.create!(id: 1, name:'Joe')
        controller = Lanes::API::ControllerBase.new(TestModel,
                                                    Lanes::API::AuthenticationProvider.new({}),
                                                    {id: 1}, {})
        assert_equal( controller.send(:perform_single_destroy), {
                          :success=>true, :message=>"Destroy succeeded", :data=>[]
                      })
        assert_empty TestModel.where(id: 1).to_a
    end


    def test_multiple_destroy
        TestModel.create!(id: 1, name:'Joe')
        TestModel.create!(id: 2, name:'Bob')

        controller = Lanes::API::ControllerBase.new(TestModel,
                                                    Lanes::API::AuthenticationProvider.new({}),
                                                    {},
                                                    [{'id'=>1}, {'id'=>2}])
        assert_equal( controller.send(:perform_multiple_destroy), {
                          :success=>true,
                          :message=>"Destroy succeeded",
                          :data=>[]
                      })
        assert_empty TestModel.all.to_a
    end

end