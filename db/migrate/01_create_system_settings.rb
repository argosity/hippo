class CreateSystemSettings < ActiveRecord::Migration[4.2]
    def change

        create_table "system_settings" do |t|
            t.jsonb  "settings", null: false, default: {}
        end

    end
end
