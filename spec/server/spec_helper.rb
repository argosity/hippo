require "lanes/spec_helper"
require_relative "minitest_assertions"
require "active_record_mocks"

require 'lanes/command'

require 'mocha/mini_test'

require "shrine/storage/memory"

# Shrine.storages = {
# }
require "shrine"
require "shrine/storage/file_system"

Lanes::Concerns::AssetUploader.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new,
}


module TestingModels
    include ActiveRecordMocks::IncludeMe

    def around(&block)
        self.with_testing_models(&block)

        # cw_root = CarrierWave.root
#         begin
#             Dir.mktmpdir('lanes-cw-root') do | dir |
# #                CarrierWave.root = dir
#                 self.with_testing_models(&block)
#             end
#         ensure
# #            CarrierWave.root = cw_root
#         end
    end

    def with_testing_models

        with_mocked_tables do |m|
            [:test_models, :tmbts, :tmhms].each do | table |
                if ActiveRecord::Base.connection.data_source_exists? table
                    ActiveRecord::Base.connection.drop_table table
                end
            end

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

class Lanes::TestCase

    def fixtures_path
        Pathname.new(__FILE__).dirname.join("..","fixtures").expand_path
    end

end
