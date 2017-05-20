class CreateSystemSettings < ActiveRecord::Migration[5.0]
    def change

        create_table "system_settings", partition_key: :tenant_id do |t|
            t.integer :tenant_id, null: false
            t.integer :configuration_id
            t.jsonb  "settings", null: false, default: {}
        end

    end
end
