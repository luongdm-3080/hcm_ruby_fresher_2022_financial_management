class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :password_digest
      t.string :remember_digest
      t.string :activation_digest
      t.boolean :activated, default: false
      t.datetime :activated_at
      t.integer :role, default: 0
      t.string :reset_digest
      t.datetime :reset_sent_at
      t.index ["email"], name: "add_index_users_on_email", unique: true

      t.timestamps
    end
  end
end
