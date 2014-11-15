require 'lanes/db/migration_helpers'

class CreateHipUsers < ActiveRecord::Migration
    def change
        create_hip_table "users" do | t |
            t.string :login, :name, :email,  null: false
            t.text   :notes
            t.string :password_digest, null: false
            t.string  :role_names,   array: true, null:false, default: []
            t.json    :options,      null: false, default:  {}
            t.hip_track_modifications
        end

        hip_add_index  :users, :role_names, using: 'gin'

    end
end
