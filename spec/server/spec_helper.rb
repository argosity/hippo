require "lanes/spec_helper"
require_relative "minitest_assertions"
require "active_record_mocks"

require 'lanes/command'
require 'lanes/workspace/extension'

# ext = Extensions.controlling
# if ext.is_a?(::Lanes::Extensions::Base)
#     Extensions.lock_controlling!
#     require_relative '../workspace/extension'
# end

module TestingModels
    include ActiveRecordMocks::IncludeMe

    def around(&block)
        self.with_testing_models(&block)
    end

    def with_testing_models
        with_mocked_tables do |m|

            m.enable_extension "hstore"

            m.create_table do |t|
                t.model_name :TestModel
                t.parent_class "Lanes::Model"
                t.belongs_to :bt, class_name: 'Tmbt'
                t.has_many   :hm, class_name: 'Tmhm'
                t.layout do |l|
                    l.integer :bt_id
                    l.string :name, :number
                end
            end
            TestModel.export_associations( :bt, :hm, writable: true )

            m.create_table do |t|
                t.model_name :Tmbt
                t.parent_class "Lanes::Model"
                t.layout do |l|
                    l.string :description, :secret_field, :notes
                end
            end

            m.create_table do |t|
                t.model_name :Tmhm
                t.parent_class "Lanes::Model"
                t.layout do |l|
                    l.integer :test_model_id
                    l.string :description, :secret_field, :notes
                end
            end
            Tmhm.blacklist_attributes :secret_field

            yield

            TestModel.blacklisted_attributes.clear if TestModel.blacklisted_attributes

        end
    end


end

class TestCase < ActiveSupport::TestCase

end
