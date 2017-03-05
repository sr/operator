class RemoveScriptPathFromTargets < ActiveRecord::Migration
  def change
    remove_column :deploy_targets, :script_path, :string
  end
end
