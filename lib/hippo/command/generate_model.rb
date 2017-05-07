require_relative 'model_attribute'

module Hippo
    module Command

        class GenerateModel < NamedCommand
            include MigrationSupport

            RESERVED_YAML_KEYWORDS = %w(y yes n no true false on off null)
            OPTIONS ||= {
                timestamps: true,
                parent:    "Hippo::Model"
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

            def generate_migration
                create_migration
            end

            def create_model
                template "lib/namespace/model.rb", "lib/#{identifier}/models/#{file_name}.rb"
                template "spec/server/model_spec.rb", "spec/server/#{file_name}_spec.rb"
                template "spec/fixtures/namespace/model.yml",
                         "spec/fixtures/#{identifier}/#{file_name}.yml"
            end

            def create_client
                self.fields.unshift ModelAttribute.parse("id:integer")
                template "client/models/model.js",
                         "#{client_dir}/models/#{file_name}.js"
                template "spec/client/models/model.spec.js",
                         "#{spec_dir}/models/#{file_name}.spec.js"
            end

            def add_route
                insert_into_file "config/routes.rb", after: /.*Hippo::API.routes.draw.*?\n/ do
                    "    resources #{namespace}::#{class_name}\n"
                end
            end

            def add_autoload
                insert_into_file "lib/#{identifier}/model.rb", before: /^end\n/ do
                    "    autoload :#{class_name}, \"#{identifier}/models/#{file_name}\"\n"
                end
            end

          private

            def computed_namespace
                # find a file and directory with the same basename
                entries = Dir.glob(self.destination_root + "/lib/*")
                name = entries.detect{ |directory|
                    FileTest.directory?(directory) && entries.detect{ |file|
                        file == directory+".rb"
                    }
                }
                name ? File.basename(name).to_s : nil
            end

            def yaml_key_value(key, value)
                if RESERVED_YAML_KEYWORDS.include?(key.downcase)
                    "'#{key}': #{value}"
                else
                    "#{key}: #{value}"
                end
            end

            def max_field_length
                @max_field_length ||= fields.map{|field|
                    field.name.length + ( field.reference? ? 3 : 0 )
                }.max
            end

            def reference_fields
                fields.select { |a| a.reference? }
            end
        end
    end
end
