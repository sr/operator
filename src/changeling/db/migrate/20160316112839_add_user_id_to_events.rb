class AddUserIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :user_id, :uuid, null: true
    add_index :events, :user_id
  end
end
