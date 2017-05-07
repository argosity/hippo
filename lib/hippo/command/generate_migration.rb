require_relative 'model_attribute'

module Hippo
    module Command

        class GenerateMigration < NamedCommand

            include MigrationSupport

            OPTIONS ||= {
                timestamps: true
            }

            class_options OPTIONS

            argument :fields, type: :array, default: []

            attr_reader :file_name, :table_name

            def set_variables
                super
                @file_name  = name.underscore
                prefix = extension.db_table_prefix
                @table_name = prefix ? "#{prefix}_#{name.tableize}" : name.tableize
            end

            def generate_module
                create_migration
            end
        end

    end
end
