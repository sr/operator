class ChangeDeployedToMerged < ActiveRecord::Migration
  def change
    rename_column :multipasses, :deployed, :merged
  end
end
