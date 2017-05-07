require "hippo/spec_helper"
require 'hippo/command'
require "temping"
require "shrine/storage/memory"

require 'rspec/expectations'

require "shrine"


RSpec.configure do |config|
  config.after do
    Temping.teardown
  end

end
require 'hippo/db/migrations'
ActiveRecord::ConnectionAdapters::PostgreSQL::Table.class_eval do
    include ::Hippo::DB::Migrations::TableDefinitionHelpers
end

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end


Shrine.storages = {
  cache: Shrine::Storage::Memory.new,
  store: Shrine::Storage::Memory.new,
}


module TestingModels

    def with_testing_models
        Temping.create :test_model, parent_class: Hippo::Model do
            with_columns do |t|
                t.integer :bt_id
                t.string :name, :number
                t.track_modifications null: true
            end
            belongs_to :bt, class_name: 'Tmbt'
            has_many   :hm, class_name: 'Tmhm'
        end

        Temping.create :tmbt, parent_class: Hippo::Model do
            with_columns do |t|
                t.string :description, :secret_field, :notes
            end
        end

        Temping.create :Tmhm, parent_class: Hippo::Model do
            with_columns do |t|
                t.integer :test_model_id
                t.string :description, :secret_field, :notes
            end
            belongs_to :test_model
        end

        yield
    ensure
        Temping.teardown
    end
end


# class Hippo::TestCase

#     def fixtures_path
#         Pathname.new(__FILE__).dirname.join("..","fixtures").expand_path
#     end

# end
