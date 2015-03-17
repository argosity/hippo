require_relative "../spec_helper"

describe "PubSub" do

    include ActiveRecordMocks::IncludeMe
    around do | test |
        with_mocked_tables do |m|
            m.create_table do |t|
                t.model_name :Evbt
                t.belongs_to :evhm, class_name: "Evhm", listen: { create: 'on_create_hm' },
                             inverse_of: :evbt
                t.layout do |l|
                    l.integer :evhm_id
                end
                t.parent_class "Lanes::Model"
            end
            class Evbt
                has_additional_events :test_one
                def on_create_hm(*args)
                    32
                end
            end

            m.create_table do |t|
                t.model_name :EventTester
                t.parent_class "Lanes::Model"
                t.belongs_to :evbt, class_name: 'Evhm'

                t.has_many   :evhm, class_name: 'Evhm', inverse_of: :event_tester

                t.layout do |l|
                    l.integer :bt_id
                    l.string :name, :number
                end
            end

            table = m.create_table do |t|
                t.model_name :Evhm
                t.belongs_to :evbt, class_name: "Evbt", listen: { save: 'on_create_bt' },
                             inverse_of: :evhm
                t.belongs_to :event_tester, class_name: "EventTester", inverse_of: :evhm,
                             listen: { save: 'on_save_event_tester' }
                t.parent_class "Lanes::Model"
                t.layout do | l |
                    l.string :mumble
                    l.integer :evbt_id, :event_tester_id
                end
            end
            def table.on_save_event_tester(*args)
            end



            test.call
        end
    end

    it "listens to other associations" do
        e=Evbt.new
        assert_equal 32, e.on_create_hm
        b=e.build_evhm
        b.expects(:on_create_bt)
        assert e.save

        et = EventTester.new
        evh = et.evhm.build
        evh.expects(:on_save_event_tester)
        assert et.save
    end

    it "registers" do
        assert_equal [ :save, :create, :update, :destroy ],EventTester.valid_event_names
        assert_equal [ :save, :create, :update, :destroy, :test_one ],Evbt.valid_event_names
    end

    it "can only observe valid events" do
        assert_raises( EventTester::InvalidEvent) do
            EventTester.observe(:invalid_event) do | ev |
            end
        end
        assert_raises( EventTester::InvalidEvent) do
            EventTester.observe(:save) do | ev |
            end
            EventTester.new.send(:fire_event,:invalid_event)
        end
        assert_raises( EventTester::InvalidEvent) do
            Evbt.observe(:test_two) do | ev |
            end
        end
        assert_raises( EventTester::InvalidEvent) do
            Evhm.observe(:test_one) do | ev |
            end
        end
        begin
            Evbt.observe(:test_one) do | ev |
            end
        rescue EventTester::InvalidEvent=>e
            assert_equal 'test_one is not a valid event for PubSubTest::Ev2', e.to_s
        end
    end

    it "events can be subscribed to" do
        EventTester.observe(:save) do | ev |

        end
    end

    it "can be fired and observed" do
        results=[]
        Evbt.observe(:test_one) do | ev, one, two |
            results = [ ev, one, two ]
        end
        evt=Evbt.new
        evt.send(:fire_event, :test_one, 3, 5 )
        assert_equal [ evt, 3, 5 ], results

        evt.send(:fire_event, :test_one, 'foo' )
        assert_equal [ evt, 'foo', nil ], results
    end


    it "can use custom event assertions" do
        assert_event_fires( Evbt, :test_one ) do
            Evbt.new.send(:fire_event, :test_one, 3, 5 )
        end
        assert_equal [ 3, 5 ], last_event_results[1..-1]
    end

end
