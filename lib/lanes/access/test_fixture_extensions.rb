module AccessFixtureTestPatches
    extend ActiveSupport::Concern

    included do
        alias_method_chain :table_rows, :custom_autoset_user_fields
    end

    def table_rows_with_custom_autoset_user_fields
        results = table_rows_without_custom_autoset_user_fields
        if model_class && model_class < ActiveRecord::Base && model_class.record_modifications
            results[ table_name ].each do | row |
                # 135138680 is the 'admin' user
                row['created_by_id'] ||= 135138680 if model_class.column_names.include?('created_by_id')
                row['updated_by_id'] ||= 135138680 if model_class.column_names.include?('updated_by_id')
            end
        end
        results
    end
end

ActiveRecord::FixtureSet.send :include, AccessFixtureTestPatches
