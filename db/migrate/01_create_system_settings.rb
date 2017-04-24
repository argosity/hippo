class CreateSystemSettings < ActiveRecord::Migration[4.2]
    def change

        create_table "system_settings" do |t|
            t.integer :configuration_id
            t.jsonb  "settings", null: false, default: {}
        end

    end
end
