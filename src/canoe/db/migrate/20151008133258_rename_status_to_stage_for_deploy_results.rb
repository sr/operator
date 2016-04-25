class RenameStatusToStageForDeployResults < ActiveRecord::Migration
  def change
    rename_column :deploy_results, :status, :stage
    change_column :deploy_results, :stage, :string, null: false, default: "initiated"
  end
end
