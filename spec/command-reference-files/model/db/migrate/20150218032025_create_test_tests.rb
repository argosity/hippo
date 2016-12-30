class CreateTestTests < ActiveRecord::Migration[5.0]
    def change
        create_table :test_tests do |t|
            t.string :name
            t.string :email

            t.timestamps null: false
        end
    end
end
