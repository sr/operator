# Changes the locks table to be a table of _current_ locks. Rows are added when
# locks are added, and removed when locks are removed. The audit log of logs is
# removed as a feature, but it's not clear to me that it is used very
# frequently. If it's ever needed in the future, I recommend adding a table of
# lock_audit_entries or similar.
class AddRepoIdToLocks < ActiveRecord::Migration
  def change
    Lock.delete_all

    remove_column :locks, :locking, :boolean, default: false
    remove_column :locks, :forced, :boolean, default: false

    add_column :locks, :repo_id, :integer, null: false
    change_column :locks, :deploy_target_id, :integer, null: false
    change_column :locks, :auth_user_id, :integer, null: false

    remove_index :locks, [:auth_user_id]
    remove_index :locks, [:deploy_target_id]
    add_index :locks, [:deploy_target_id, :repo_id], unique: true
  end
end
