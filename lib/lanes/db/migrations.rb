require 'pathname'

module Lanes
    module DB
        module Migrations
            # The `paths` array is an extension point for other
            mattr_accessor :paths
            self.paths = [
              Pathname.new(__FILE__).dirname.join("../../../db/migrate").realpath
            ]

            # Migration table definition helpers methods
            module TableDefinitionHelpers
                # track user modifications
                def track_modifications(create_only: false, null: false)
                    column(:created_at, :datetime,   null: null)
                    column(:created_by_id, :integer, null: null)
                    return if create_only

                    column(:updated_at, :datetime,   null: null)
                    column(:updated_by_id, :integer, null: null)
                end
            end
        end
    end
end



ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnMethods.class_eval do
    include ::Lanes::DB::Migrations::TableDefinitionHelpers
end
