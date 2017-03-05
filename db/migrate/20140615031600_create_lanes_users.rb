class CreateLanesUsers < ActiveRecord::Migration
    def change
        create_table "lanes_users" do | t |
            t.string :login, :name, :email,  null: false
            t.string :password_digest, null: false
            t.string  "role_names",   array: true, null:false, default: []
            t.jsonb   "options",      null: false, default:  {}
            t.timestamps null:false
        end
        add_index  :lanes_users, :role_names, using: 'gin'
    end
end
