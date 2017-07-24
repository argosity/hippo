class CreateUsers < ActiveRecord::Migration[5.0]
    def change
        create_table :users do | t |
            t.references :tenant, null: false
            t.string :login, :name, :email,  null: false
            t.string :password_digest, null: false
            t.string :role_names,   array: true, null:false, default: []
            t.jsonb  :options,      null: false, default:  {}
            t.timestamps null:false
        end

        add_index :users, 'lower(login), tenant_id', name: 'index_users_on_login_and_tenant_id', unique: true
    end
end
