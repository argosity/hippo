class CreateAssets < ActiveRecord::Migration[5.0]
    def change

        create_table "assets" do |t|
            t.references :owner, polymorphic: true, null: false
            t.integer    :order
            t.jsonb      :file_data, null: false, default: {}
        end

        add_index :assets, [:owner_id, :owner_type]

    end
end
