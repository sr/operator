class DropLockPathFromDeployTargets < ActiveRecord::Migration
  def change
    remove_column :deploy_targets, :lock_path, :string
  end
end
