class CreateUniqueIndexOnAuthUsersUid < ActiveRecord::Migration
  def change
    remove_index :auth_users, column: :email
    change_column :auth_users, :uid, :string, null: false
    add_index :auth_users, :uid, unique: true
  end
end
