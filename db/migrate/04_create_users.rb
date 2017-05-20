class CreateUsers < ActiveRecord::Migration[5.0]
    def change
        create_table :users, partition_key: :tenant_id do | t |
            t.integer :tenant_id, null: false
            t.string :login, :name, :email,  null: false
            t.string :password_digest, null: false
            t.string  "role_names",   array: true, null:false, default: []
            t.jsonb   "options",      null: false, default:  {}
            t.timestamps null:false
        end

        add_index :users, [:login, :tenant_id], unique: true
    end
end
