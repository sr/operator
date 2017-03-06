class CreateAuthUsers < ActiveRecord::Migration
  def change
    create_table :auth_users do |t|
      t.string :email
      t.string :name
      t.string :uid
      t.string :token
      t.timestamps
    end
    add_index :auth_users, :email
  end
end
