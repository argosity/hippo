require "lanes/spec_helper"
require 'lanes/command'
require "temping"
require "shrine/storage/memory"

require 'rspec/expectations'

require "shrine"
require "shrine/storage/file_system"

Lanes::Concerns::AssetUploader.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new,
}

RSpec.configure do |config|
  config.after do
    Temping.teardown
  end

end

module TestingModels

    # around(:each) do |example|
    #     self.with_testing_models do
    #         example.run
    #     end
    # end
    # def around(&block)
    #     self.with_testing_models(&block)
    # end

    def with_testing_models

        # [:test_models, :tmbts, :tmhms].each do | table |
        #     if ActiveRecord::Base.connection.data_source_exists? table
        #         ActiveRecord::Base.connection.drop_table table
        #     end
        # end
        Temping.create :test_model do

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
        Temping.teardown
    end
end


# class Lanes::TestCase

#     def fixtures_path
#         Pathname.new(__FILE__).dirname.join("..","fixtures").expand_path
#     end

# end
