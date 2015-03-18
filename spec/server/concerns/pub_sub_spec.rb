require_relative "../spec_helper"

describe "PubSub" do

    include ActiveRecordMocks::IncludeMe
    around do | test |
        with_mocked_tables do |m|

            class A < Lanes::Model
                has_additional_events :test_one
                def on_save_b(*args)
                end
                def on_save_event_tester(*args)
                end
            end
            m.create_table do |t|
                t.model_name :A
                t.parent_class "Lanes::Model"
                t.belongs_to :b_model, class_name: "B", listen: { save: :on_save_b },
                             inverse_of: :a_model

                t.belongs_to :event_tester, class_name: "EventTester", inverse_of: :a_models,
                             listen: { save: 'on_save_event_tester' }

                t.layout do |l|
                    l.integer :b_model_id, :b_id
                    l.integer :event_tester_id
                end
            end

            class B < Lanes::Model
                def on_save_a(*args)
                end
            end
            table = m.create_table do |t|
                t.model_name :B
                t.parent_class "Lanes::Model"
                t.has_one :a_model, class_name: "A", listen: { save: 'on_save_a' },
                             inverse_of: :b_model
                t.layout do | l |
                    l.string :mumble
                end
            end

            class EventTester < Lanes::Model
            end

            m.create_table do |t|
                t.model_name :EventTester
                t.parent_class "Lanes::Model"
                t.has_many   :a_models, class_name: 'A', inverse_of: :event_tester

                t.layout do |l|
                    l.string :name, :number
                end
            end

            test.call

        end
    end

    it "listens to other associations" do
        a=A.new
        b=a.build_b_model
        assert b.a_model
        a.expects(:on_save_b)
        assert a.save

        et = EventTester.new
        a=et.a_models.build
        a.expects(:on_save_event_tester)
        et.save
    end

    it "registers" do
        assert_equal [ :save, :create, :update, :destroy ], EventTester.valid_event_names
        assert_equal [ :save, :create, :update, :destroy, :test_one ], A.valid_event_names
    end

    it "can only observe valid events" do
        assert_raises(EventTester::InvalidEvent) do
            EventTester.observe(:invalid_event) do | ev |
            end
        end
        assert_raises(EventTester::InvalidEvent) do
            B.observe(:test_two) do | ev |
            end
        end
        assert_raises(EventTester::InvalidEvent) do
            A.observe(:glub_glub) do | ev |
            end
        end
        begin
            B.observe(:test_one) do | ev |
            end
        rescue EventTester::InvalidEvent=>e
            assert_equal 'test_one is not a valid event for B', e.to_s
        end
    end

    it "events can be subscribed to" do
        EventTester.observe(:save) do | ev |
        end
    end

    it "can be fired and observed" do
        results=[]
        A.observe(:test_one) do | ev, one, two |
            results = [ ev, one, two ]
        end
        a=A.new
        a.send(:fire_pubsub_event, :test_one, 3, 5 )
        assert_equal [a, 3, 5], results

        a.send(:fire_pubsub_event, :test_one, 'foo' )
        assert_equal [a, 'foo', nil], results
    end


    it "can use custom event assertions" do
        assert_event_fires(A, :test_one) do
            A.new.send(:fire_pubsub_event, :test_one, 3, 5)
        end
        assert_equal [ 3, 5 ], last_event_results[1..-1]
    end

end
