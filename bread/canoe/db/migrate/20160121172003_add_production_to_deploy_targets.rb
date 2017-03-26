class AddProductionToDeployTargets < ActiveRecord::Migration
  def change
    add_column :deploy_targets, :production, :boolean, null: false, default: false
  end
end
