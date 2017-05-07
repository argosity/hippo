module AccessFixtureTestPatches

    def table_rows
        results = super
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

ActiveRecord::FixtureSet.prepend AccessFixtureTestPatches
