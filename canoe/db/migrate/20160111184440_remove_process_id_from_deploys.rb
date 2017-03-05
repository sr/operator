class RemoveProcessIdFromDeploys < ActiveRecord::Migration
  def change
    remove_column :deploys, :process_id, :string
  end
end
