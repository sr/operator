class AddDeployedStatusToMultipasses < ActiveRecord::Migration
  def change
    add_column :multipasses, :deployed, :boolean, default: false
  end
end
