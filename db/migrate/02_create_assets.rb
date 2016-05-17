class CreateAssets < ActiveRecord::Migration
    def change

        create_table "assets" do |t|
            t.string     :file, null: false

            t.references :owner, polymorphic: true, null: false
            t.integer    :order
            t.jsonb      :metadata, null: false, default: {}
        end

        add_index :assets, [:owner_id, :owner_type]

    end
end
