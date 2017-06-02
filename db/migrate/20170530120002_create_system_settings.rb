class CreateSystemSettings < ActiveRecord::Migration[5.0]
    def change

        create_table :system_settings do |t|
            t.references :tenant, null: false
            t.jsonb  "settings", null: false, default: {}
        end

    end
end
