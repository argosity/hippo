class CreateSubscriptions < ActiveRecord::Migration[5.0]
    def change
        create_table :subscriptions do |t|
            t.string :subscription_id, index: { unique: true }
            t.string :name, :description, null: false
            t.decimal :price, precision: 10, scale: 2, null: false
            t.integer :trial_duration, default: 0
        end
        add_column :tenants, :metadata, :jsonb, default: {}, null: false
        add_reference :tenants, :subscription, foreign_key: true
    end
end
