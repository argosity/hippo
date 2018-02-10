class CreatePages < ActiveRecord::Migration[5.0]
    def change
        create_table :pages do |t|
            t.references :tenant, null: false, foreign_key: true
            t.references :owner, polymorphic: true, index: true
            t.text :html, null: false
            t.jsonb :contents, null: false
        end
    end
end
