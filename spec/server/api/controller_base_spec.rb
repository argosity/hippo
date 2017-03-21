require_relative "../spec_helper"
require 'lanes/access/user'


class GodUser
    def can_read?(*args)
    end
    def can_write?(*args)
        true
    end
    def can_delete?(*args)
        true
    end
end

class NullAuthProvider
    def current_user
        @user ||= GodUser.new
    end
end

describe "ControllerBase" do # < Lanes::TestCase
    include TestingModels

    around(:each) do |example|
        with_testing_models do
            example.run
        end
    end


    it "can retrieve" do
        1.upto(10){|i| TestModel.create!(id: i, name:'test') }
        controller = Lanes::API::ControllerBase.new(TestModel,
                                                    Lanes::API::AuthenticationProvider.new({}),
                                                    {id: 1})
        expect(controller.send(:perform_retrieval))
            .to match(
                    success: true, message: "Retrieve succeeded",
                    data: a_hash_including({"id"=>1, "bt_id"=>nil, "name"=>"test", "number"=>nil})
                )
    end

    it "can make a single update" do
        person = TestModel.create!(id: 21, name:'Joe')
        controller = Lanes::API::ControllerBase.new(TestModel,
                                                    NullAuthProvider.new,
                                                    {id: person.id}, {name:'Bob'})
        expect(controller.send(:perform_single_update))
            .to match(
                    :success=>true, :message=>"Update succeeded",
                    data: a_hash_including("id"=>person.id, "bt_id"=>nil, "name"=>"Bob", "number"=>nil)
                )

        expect(person.reload.name).to eq('Bob')
    end

    it 'can update multiple records' do
        TestModel.create!(id: 1, name:'Joe')
        TestModel.create!(id: 2, name:'Bob')
        def TestModel.access_limits_for_query(query, user, params)
            query.where(name:'Joe')
        end
        controller = Lanes::API::ControllerBase.new(TestModel,
                                                    NullAuthProvider.new,
                                                    {},
                                                    [{'id'=>1}, {'id'=>2}])

        expect(controller.send(:perform_multiple_updates))
              .to match(success: true, message: "Update succeeded",
                        data: array_including(
                            a_hash_including("id"=>1, "bt_id"=>nil, "name"=>"Joe", "number"=>nil)
                        )
                       )
    end

    it 'can destroy a single record' do
        TestModel.create!(id: 1, name:'Joe')
        controller = Lanes::API::ControllerBase.new(TestModel,
                                                    NullAuthProvider.new,
                                                    {id: 1}, {})
        expect(controller.send(:perform_single_destroy))
            .to eq(success: true, message: "Destroy succeeded", data: [])
        expect(TestModel.where(id: 1).first).to be_nil
    end


    it 'can destroy a multiple records' do
        TestModel.create!(id: 1, name:'Joe')
        TestModel.create!(id: 2, name:'Bob')

        controller = Lanes::API::ControllerBase.new(TestModel,
                                                    NullAuthProvider.new,
                                                    {},
                                                    [{'id'=>1}, {'id'=>2}])
        expect( controller.send(:perform_multiple_destroy))
            .to match(success: true, message: "Destroy succeeded", data: [])
        expect(TestModel.all.to_a).to be_empty
    end

end
