class AddEnabledToDeployTargets < ActiveRecord::Migration
  def change
    add_column :deploy_targets, :enabled, :boolean, null: false, default: true
    add_index :deploy_targets, :enabled
  end
end
