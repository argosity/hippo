require_relative 'model_attribute'

module Hippo
    module Command
        module MigrationSupport
            def create_migration
                migration = existing_migration ||
                  migration_timestamp + "_create_#{table_name}.rb"
                self.fields = fields.map{ |field| ModelAttribute.parse(field) }
                template "db/create_table_migration.rb", "db/migrate/#{migration}"
            end

          private

            def existing_migration
                migrations = Pathname.glob("#{destination_root}/db/migrate/[0-9]*_create_#{table_name}.rb")
                migrations.any? ? migrations.first.basename.to_s : nil
            end

            def migration_timestamp
                ENV['MIGRATION_TIMESTAMP'] || Time.now.utc.strftime("%Y%m%d%H%M%S")
            end

            def fields_with_index
                fields.select { |a| !a.reference? && a.has_index? }
            end
        end
    end
end
