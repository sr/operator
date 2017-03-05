class RemovesLockedAndLockableFromDeployTargets < ActiveRecord::Migration
  def change
    remove_column :deploy_targets, :lockable, :boolean, default: false
    remove_column :deploy_targets, :locked, :boolean
  end
end
