class CreateSystemSettings < ActiveRecord::Migration
    def change

        create_table "system_settings" do |t|
            t.string "logo"
            t.jsonb  "settings", null: false, default: {}
        end

    end
end
