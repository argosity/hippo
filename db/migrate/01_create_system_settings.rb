class CreateSystemSettings < ActiveRecord::Migration
    def change

        create_table "system_settings" do |t|
            t.jsonb  "settings", null: false, default: {}
        end

    end
end
