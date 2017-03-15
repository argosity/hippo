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
require 'lanes/db/migrations'
ActiveRecord::ConnectionAdapters::PostgreSQL::Table.class_eval do
    include ::Lanes::DB::Migrations::TableDefinitionHelpers
end

module TestingModels

    def with_testing_models
        Temping.create :test_model, parent_class: Lanes::Model do
            with_columns do |t|
                t.integer :bt_id
                t.string :name, :number
                t.track_modifications
            end
            belongs_to :bt, class_name: 'Tmbt', export: { writable: true }
            has_many   :hm, class_name: 'Tmhm', export: { writable: true }
        end

        Temping.create :tmbt, parent_class: Lanes::Model do
            with_columns do |t|
                t.string :description, :secret_field, :notes
            end
        end

        Temping.create :Tmhm, parent_class: Lanes::Model do
            with_columns do |t|
                t.integer :test_model_id
                t.string :description, :secret_field, :notes
            end
            blacklist_attributes :secret_field
        end

        yield

        Temping.teardown
    end
end


# class Lanes::TestCase

#     def fixtures_path
#         Pathname.new(__FILE__).dirname.join("..","fixtures").expand_path
#     end

# end
