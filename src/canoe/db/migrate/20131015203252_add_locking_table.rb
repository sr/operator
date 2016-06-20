class AddLockingTable < ActiveRecord::Migration
  def change
    create_table :locks do |t|
      t.integer :deploy_target_id
      t.integer :auth_user_id
      t.boolean :locking, default: false
      t.boolean :forced,  default: false
      t.timestamps
    end
    add_index :locks, :deploy_target_id
    add_index :locks, :auth_user_id
  end
end
